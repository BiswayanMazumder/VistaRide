import React from 'react'
import { Link } from 'react-router-dom'

export default function Service_category_details() {
    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv" style={{ width: '90%', display: 'flex', flexDirection: 'row', justifyContent: 'space-between', position: 'relative' }}>
                    {'Service Category'}
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jikd" style={{ fontSize: '15px', marginTop: '15px', display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
                            {(<svg width="10" height="10" viewBox="0 0 50 50" xmlns="http://www.w3.org/2000/svg">
                                <rect x="22" y="0" width="6" height="50" fill="black" />
                                <rect x="0" y="22" width="50" height="6" fill="black" />
                            </svg>)}
                            <div style={{ marginLeft: '10px' }}>{'Add'}</div>
                        </div>
                    </Link>
                </div>
            </div>
        </div>
    )
}
