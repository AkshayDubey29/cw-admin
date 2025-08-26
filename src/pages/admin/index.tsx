import { useEffect } from 'react'
import { useRouter } from 'next/router'

export default function AdminIndex() {
  const router = useRouter()

  useEffect(() => {
    // Redirect to the main dashboard
    router.push('/admin/dashboard')
  }, [router])

  return (
    <div style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      height: '100vh',
      fontFamily: 'Arial, sans-serif'
    }}>
      <div>
        <h1>CreatWorx Admin</h1>
        <p>Loading admin dashboard...</p>
      </div>
    </div>
  )
}
