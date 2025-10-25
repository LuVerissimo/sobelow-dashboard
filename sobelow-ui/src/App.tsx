import { Route, Routes } from 'react-router-dom'
import { HomePage, ScanPage, } from './pages'

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />}/>
      <Route path="/scans/:scanId" element={<ScanPage />}/>
    </Routes>
  )
}

export default App