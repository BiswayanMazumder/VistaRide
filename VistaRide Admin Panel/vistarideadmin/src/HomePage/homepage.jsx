import React from 'react'
import { Link } from 'react-router-dom'

export default function Homepage() {
    return (
        <div className='webbody'>
            <div className="jffnjvfnv">
                <div className="mnvnfv">
                    <div className="jjdnjvnv">
                        <img src="https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2FScreenshot_2024-11-22_204328-removebg-preview.png?alt=media&token=53712449-daaa-4f70-bb92-0ca64793111e" alt="" height={"80px"} width={"80px"} />
                        <div className="enjfndj">
                            <svg width="100" height="30" xmlns="http://www.w3.org/2000/svg">
                                <rect width="100" height="30" fill="white" rx="5"></rect>
                                <text x="50%" y="50%" font-family="'Lobster', cursive" font-size="21" fill="black" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">VistaRide</text>
                            </svg>
                        </div>

                    </div>
                    <div className="nnnvnfnvf">
                        HOME
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk">
                            Dashboard
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Server Monitoring
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        MEMBERS
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk">
                            Admin
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Rider
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Drivers
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Organization
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        SERVICES
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk">
                            Manage Service Category
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Vehicle Type
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Rental Packages
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Driver Approval
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        BOOKINGS AND REPORTS
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk">
                            Bookings
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Manage Locations
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            God's View
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px',marginBottom:'10px'}}>
                            Heat View
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px',marginBottom:'10px'}}>
                            Reports
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        SETTINGS AND UTILITIES
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk">
                            General
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Currency
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px'}}>
                            Send Push Notification
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px',marginBottom:'10px'}}>
                            Documents
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px',marginBottom:'10px'}}>
                            Vehicle Make
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }} to="/dashboard">
                        <div className="dnjnkfjk" style={{marginTop:'5px',marginBottom:'10px'}}>
                            Vehicle Model
                        </div>
                    </Link>
                </div>
                <div className="dnjfnjn">

                </div>
            </div>
        </div>
    )
}
