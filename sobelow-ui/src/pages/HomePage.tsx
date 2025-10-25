import axios from 'axios';
import { useState, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';

const API = 'http://localhost:4000/api';

export const HomePage = () => {
    const [url, setUrl] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleSubmit = async (e: FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            const res = await axios.post(`${API}/projects`, { url });

            navigate(`/scans/${res.data.data.id}`);
        } catch (err) {
            console.error(err);
            alert('Failed to start scan. Check the URL');
            setLoading(false);
        }
    };
    return (
        <div style={{ padding: '20px' }}>
            <h1>Sobelow Security Dashboard</h1>
            <form onSubmit={handleSubmit}>
                <input
                    type="text"
                    value={url}
                    onChange={(e) => setUrl(e.target.value)}
                    placeholder="https://github.com/fly-apps/hello_phoenix.git"
                    style={{ width: '300px', padding: '8px', fontSize: '1rem' }}
                />
                <button
                    type="submit"
                    disabled={loading}
                    style={{
                        padding: '8px',
                        fontSize: '1rem',
                        marginLeft: '10px',
                    }}
                >
                    {loading ? 'Starting ...' : 'Scan Project'}
                </button>
            </form>
        </div>
    );
};
