import axios from 'axios';
import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';

const API = 'http://localhost:4000/api';

interface Scan {
    id: string;
    status: 'pending' | 'running' | 'complete' | 'failed';
}
interface Finding {
    id: string;
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

    useEffect(() => {
        const poll = async () => {
            try {
                const res = await axios.get(`${API}/scans/${scanId}`);
                const scanData: Scan = res.data.data;
                setScan(scanData);

                if (scanData.status === 'complete') {
                    clearInterval(intervalId);
                    const findingsRes = await axios.get(
                        `${API}/scans/${scanId}/findings`,
                        { params: { page: page } }
                    );
                    setFindings(findingsRes.data.data);
                } else if (scanData.status === 'failed') {
                    clearInterval(intervalId);
                }
            } catch (err) {
                console.error('Failed to poll', err);
                clearInterval(intervalId);
            }
        };

        const intervalId = setInterval(poll, 3000);
        poll();

        return () => clearInterval(intervalId);
    }, [scanId]);

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
    }, [scan, page]);

    if (!scan || scan.status === 'pending' || scan.status === 'running') {
        return (
            <div style={{ padding: '20px' }}>
                Scanning project... This may take awhile. Status:{' '}
                {scan?.status || 'pending'}
            </div>
        );
    }

    if (scan.status === 'failed') {
        return (
            <div style={{ padding: '20px', color: 'red' }}>
                Scan failed. Please check the repo URL.
            </div>
        );
    }

    return (
        <div style={{ padding: '20px' }}>
            <h2>Scan Complete! ({totalEntries} findings)</h2>

            <div style={{ margin: '10px 0' }}>
                <button
                    onClick={() => setPage((p) => p - 1)}
                    disabled={page <= 1}
                >
                    Previous
                </button>
                <span style={{ margin: '0 10px' }}>
                    Page {page} of {totalPages}
                </span>
                <button
                    onClick={() => setPage((p) => p + 1)}
                    disabled={page >= totalPages}
                >
                    Next
                </button>
            </div>

            <table
                style={{
                    borderCollapse: 'collapse',
                    width: '100%',
                    border: '1px solid #ddd',
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
        </div>
    );
};
