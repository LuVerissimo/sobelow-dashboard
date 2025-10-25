import axios from 'axios';
import { useEffect, useRef, useState } from 'react';
import { useParams } from 'react-router-dom';

const API = 'http://localhost:4000/api';

interface Scan {
    id: number;
    status: 'pending' | 'running' | 'complete' | 'failed';
}

interface Finding {
    id: number;
    vulnerability_type: string;
    file: string;
    line: number;
    confidence: string;
    severity: string;
    description: string;
}

interface FindingsResponse {
    data: Finding[];
    page_number: number;
    total_pages: number;
    total_entries: number;
}

export const ScanPage = () => {
    const { scanId } = useParams();
    const [scan, setScan] = useState<Scan | null>(null);
    const [findings, setFindings] = useState<Finding[]>([]);
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(0);
    const [totalEntries, setTotalEntries] = useState(0);
    const [loadingFindings, setLoadingFindings] = useState(false);

    const intervalRef = useRef<NodeJS.Timer | null>(null);
    const abortControllerRef = useRef<AbortController | null>(null);

    const fetchScan = async () => {
        if (!scanId) return;
        try {
            const res = await axios.get<{ data: Scan }>(
                `${API}/scans/${scanId}`
            );
            setScan(res.data.data);
        } catch (err) {
            console.error('Failed to fetch scan', err);
        }
    };

    const pollScan = () => {
        // clear any existing interval
        if (intervalRef.current) clearInterval(intervalRef.current);

        intervalRef.current = setInterval(async () => {
            await fetchScan();
        }, 3000);
    };

    const handleCancel = async () => {
        if (!scanId || !scan) return;
        try {
            await axios.post(`${API}/scans/${scanId}/cancel`);
            setScan({ ...scan, status: 'failed' }); // immediate feedback
        } catch (err) {
            console.error('Failed to cancel scan', err);
            alert('Could not cancel the scan.');
        }
    };

    // --- Polling logic ---
    useEffect(() => {
        if (!scanId) return;

        fetchScan();
        pollScan(); 

        return () => {
            if (intervalRef.current) clearInterval(intervalRef.current);
        };
    }, [scanId]);

    // Stop polling when scan reaches a final state
    useEffect(() => {
        if (scan?.status === 'complete' || scan?.status === 'failed') {
            if (intervalRef.current) {
                clearInterval(intervalRef.current);
                intervalRef.current = null;
            }
        }
    }, [scan]);

    // --- Fetch findings when scan is complete or page changes ---
    useEffect(() => {
        if (scan?.status !== 'complete' || !scanId) return;

        // cancel previous fetch if any
        if (abortControllerRef.current) abortControllerRef.current.abort();
        const controller = new AbortController();
        abortControllerRef.current = controller;

        const fetchFindings = async () => {
            setLoadingFindings(true);
            try {
                const res = await axios.get<FindingsResponse>(
                    `${API}/scans/${scanId}/findings`,
                    {
                        params: { page },
                        signal: controller.signal,
                    }
                );
                setFindings(res.data.data);
                setTotalPages(res.data.total_pages);
                setTotalEntries(res.data.total_entries);
            } catch (err) {
                if (!axios.isCancel(err)) {
                    console.error('Failed to fetch findings', err);
                }
            } finally {
                setLoadingFindings(false);
            }
        };

        fetchFindings();
        return () => controller.abort();
    }, [scan, page, scanId]);

    // --- Render ---
    if (!scan || scan.status === 'pending' || scan.status === 'running') {
        return (
            <div style={{ padding: '20px' }}>
                Scanning project... Status: {scan?.status || 'pending'}
                <button onClick={handleCancel} style={{ marginLeft: '10px' }}>
                    Cancel
                </button>
            </div>
        );
    }

    if (scan.status === 'failed') {
        return (
            <div style={{ padding: '20px', color: 'red' }}>
                Scan failed. Check the repo URL.
            </div>
        );
    }

    return (
        <div style={{ padding: '20px' }}>
            <h2>Scan Complete! ({totalEntries} findings)</h2>

            {totalEntries > 0 && (
                <div style={{ margin: '10px 0' }}>
                    <button
                        onClick={() => setPage((p) => Math.max(1, p - 1))}
                        disabled={page <= 1}
                    >
                        Previous
                    </button>
                    <span style={{ margin: '0 10px' }}>
                        Page {page} of {totalPages}
                    </span>
                    <button
                        onClick={() =>
                            setPage((p) => Math.min(totalPages, p + 1))
                        }
                        disabled={page >= totalPages}
                    >
                        Next
                    </button>
                </div>
            )}

            {loadingFindings ? (
                <p>Loading findings...</p>
            ) : findings.length > 0 ? (
                <table style={{ borderCollapse: 'collapse', width: '100%' }}>
                    <thead>
                        <tr>
                            {[
                                'Severity',
                                'Type',
                                'File',
                                'Line',
                                'Description',
                            ].map((col) => (
                                <th
                                    key={col}
                                    style={{
                                        border: '1px solid #ddd',
                                        padding: '8px',
                                        textAlign: 'left',
                                    }}
                                >
                                    {col}
                                </th>
                            ))}
                        </tr>
                    </thead>
                    <tbody>
                        {findings.map((f) => (
                            <tr key={`${f.id}-${page}`}>
                                <td
                                    style={{
                                        border: '1px solid #ddd',
                                        padding: '8px',
                                    }}
                                >
                                    {f.severity}
                                </td>
                                <td
                                    style={{
                                        border: '1px solid #ddd',
                                        padding: '8px',
                                    }}
                                >
                                    {f.vulnerability_type}
                                </td>
                                <td
                                    style={{
                                        border: '1px solid #ddd',
                                        padding: '8px',
                                    }}
                                >
                                    <code>{f.file}</code>
                                </td>
                                <td
                                    style={{
                                        border: '1px solid #ddd',
                                        padding: '8px',
                                    }}
                                >
                                    {f.line}
                                </td>
                                <td
                                    style={{
                                        border: '1px solid #ddd',
                                        padding: '8px',
                                    }}
                                >
                                    {f.description}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            ) : (
                <p>No findings reported for this scan.</p>
            )}
        </div>
    );
};
