import type { NextApiRequest, NextApiResponse } from 'next'

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  res.status(200).json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'cw-admin',
    version: process.env.NEXT_PUBLIC_APP_VERSION || '1.0.0'
  })
}
