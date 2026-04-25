import { useState, useEffect } from 'react'

function App() {
  const [health, setHealth] = useState(null)

  useEffect(() => {
    fetch('/api/health')
      .then((r) => r.json())
      .then((data) => setHealth(data.status))
      .catch(() => setHealth('no api'))
  }, [])

  return (
    <main style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>App</h1>
      <p>API status: <strong>{health ?? 'checking...'}</strong></p>
    </main>
  )
}

export default App
