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

    const intervalRef = useRef<number | null>(null);

    const handleCancel = async () => {
        if (scanId) {
            try {
                await axios.post(`${API}/scans/${scanId}/cancel`);
            } catch (err) {
                console.error('Failed to cancel scan', err);
                alert('Could not cancel the scan.');
            }
        }
    };

    useEffect(() => {
        setScan(null);
        setFindings([]);
        setPage(1);
        setTotalPages(0);
        setTotalEntries(0);

        if (intervalRef.current) {
            clearInterval(intervalRef.current);
            intervalRef.current = null;
        }
    }, [scanId]);

    const poll = async () => {
        try {
            const res = await axios.get(`${API}/scans/${scanId}`);
            const scanData: Scan = res.data.data;
            setScan(scanData);
        } catch (err) {
            console.error('Failed to poll status', err);

            if (intervalRef.current) {
                clearInterval(intervalRef.current);
                intervalRef.current = null;
            }

            setScan((prev) =>
                prev
                    ? { ...prev, status: 'failed' }
                    : { id: parseInt(scanId || '0'), status: 'failed' }
            );
        }
    };

    useEffect(() => {
        const isPollingNeeded =
            scan?.status === 'pending' || scan?.status === 'running';

        if (isPollingNeeded && !intervalRef.current) {
            poll();
            intervalRef.current = setInterval(poll, 3000);
        } else if (!isPollingNeeded && intervalRef.current) {
            clearInterval(intervalRef.current);
            intervalRef.current = null;
        }

        return () => {
            if (intervalRef.current) {
                clearInterval(intervalRef.current);
                intervalRef.current = null;
            }
        };
    }, [scan, scanId]);

    useEffect(() => {
        if (scan?.status === 'complete') {
            const fetchFindings = async () => {
                try {
                    const findingsRes = await axios.get<FindingsResponse>(
                        `${API}/scans/${scanId}/findings`,
                        {
                            params: { page: page },
                        }
                    );
                    setFindings(findingsRes.data.data);
                    setTotalPages(findingsRes.data.total_pages);
                    setTotalEntries(findingsRes.data.total_entries);
                } catch (err) {
                    console.error('Failed to fetch findings', err);
                }
            };
            fetchFindings();
        }
    }, [scan, page, scanId]);

    if (!scan || scan.status === 'pending' || scan.status === 'running') {
        return (
            <div style={{ padding: '20px' }}>
                Scanning project... This may take awhile. Status:{' '}
                {scan?.status || 'pending'}
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
                        onClick={() => setPage((p) => p - 1)}
                        disabled={page <= 1}
                        style={{ padding: '5px 10px', marginRight: '5px' }}
                    >
                        Previous
                    </button>
                    <span style={{ margin: '0 10px' }}>
                        Page {page} of {totalPages}
                    </span>
                    <button
                        onClick={() => setPage((p) => p + 1)}
                        disabled={page >= totalPages}
                        style={{ padding: '5px 10px', marginLeft: '5px' }}
                    >
                        Next
                    </button>
                </div>
            )}

            {findings.length > 0 ? (
                <table
                    style={{
                        borderCollapse: 'collapse',
                        width: '100%',
                        border: '1px solid #ddd',
                        marginTop: '10px',
                    }}
                >
                    <thead style={{ background: '#f4f4f4' }}>
                        <tr>
                            <th
                                style={{
                                    border: '1px solid #ddd',
                                    padding: '8px',
                                    textAlign: 'left',
                                }}
                            >
                                Severity
                            </th>
                            <th
                                style={{
                                    border: '1px solid #ddd',
                                    padding: '8px',
                                    textAlign: 'left',
                                }}
                            >
                                Type
                            </th>
                            <th
                                style={{
                                    border: '1px solid #ddd',
                                    padding: '8px',
                                    textAlign: 'left',
                                }}
                            >
                                File
                            </th>
                            <th
                                style={{
                                    border: '1px solid #ddd',
                                    padding: '8px',
                                    textAlign: 'left',
                                }}
                            >
                                Line
                            </th>
                            <th
                                style={{
                                    border: '1px solid #ddd',
                                    padding: '8px',
                                    textAlign: 'left',
                                }}
                            >
                                Description
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        {findings.map((f) => (
                            <tr key={f.id}>
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
