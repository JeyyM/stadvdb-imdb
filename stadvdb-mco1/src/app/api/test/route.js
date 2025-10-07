import { createConnection } from '@/lib/db.js'
import { NextResponse } from 'next/server'

export async function GET() {
    try {
        const db = await createConnection()
        const [rows] = await db.query("SELECT * FROM name_basics LIMIT 10")
        await db.end()
        return NextResponse.json(rows)
    } catch (error) {
        console.error('Database query failed:', error)
        return NextResponse.json({ error: error.message }, { status: 500 })
    }
}