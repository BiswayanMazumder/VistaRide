import React from 'react'
import { Link } from 'react-router-dom';
export default function LandingPage_Laptop() {
    return (
        <div className='webbody'>
            <div className="ehfjfv">
                <div className="hfejfe">
                    VistaRide
                    <div className="ebfn">
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="eefebf">
                                Ride
                            </div>
                        </Link>
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="eefebf">
                                Drive
                            </div>
                        </Link>
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="eefebf">
                                Business
                            </div>
                        </Link>
                    </div>
                </div>
            </div>
            <div className="nbnrnjrnf">
                <div className="ehfefbefb">
                    <div className="jnjvn">
                        Go anywhere with<br />VistaRide
                    </div>
                    <div className="jnjvn" style={{ marginTop: '30px' }}>
                        <input type="text" className='ebfbebfeh' placeholder=' Pickup location' />
                    </div>
                    <div className="jnjvn" style={{ marginTop: '20px' }}>
                        <input type="text" className='ebfbebfeh' placeholder=' Dropoff location' />
                    </div>
                    <Link style={{ textDecoration: 'none', color: 'white' }}>
                    <div className="jffnrn">
                        See prices
                    </div>
                    </Link>
                </div>
            </div>
        </div>
    )
}
