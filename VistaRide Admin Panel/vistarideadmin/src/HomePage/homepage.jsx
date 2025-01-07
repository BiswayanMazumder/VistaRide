import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import Dashboard from '../Sidebar Options/dashboard';
import Drivers from '../Sidebar Options/Drivers';
import Ridepage from '../Rides Page/ridepage';
import Cab_category_page from '../Cab Category/cab_category_page';
import Riders from '../Cab Category/Rider Details/riders';
import Driverapproval from '../Driver Approval/driverapproval';
import Addlocations from '../Manage Locations/addlocations';
import Servicable_Locations from '../Manage Locations/Servicable_Locations';
import Heatview from '../Aerial Views(Heat or god)/heatview';

export default function Homepage() {
    // State to track the selected option index
    const [selectedIndex, setSelectedIndex] = useState(0);

    // Handle option click to update the selected index
    const handleOptionClick = (index) => {
        setSelectedIndex(index);
    };

    return (
        <div className='webbody' style={{overflow:'hidden'}}>
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
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 0 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 0 ? 'white' : 'black'
                            }} 
                            onClick={() => handleOptionClick(0)}
                        >
                            Dashboard
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 1 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 1 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(1)}
                        >
                            Server Monitoring
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        MEMBERS
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 2 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 2 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(2)}
                        >
                            Admin
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 3 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 3 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(3)}
                        >
                            Rides
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 4 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 4 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(4)}
                        >
                            Drivers
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 5 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 5 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(5)}
                        >
                            Riders
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        SERVICES
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 6 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 6 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(6)}
                        >
                            Manage Service Category
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 7 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 7 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(7)}
                        >
                            Vehicle Type
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 8 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 8 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(8)}
                        >
                            Rental Packages
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}>
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 9 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 9 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(9)}
                        >
                            Driver Approval
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        BOOKINGS AND REPORTS
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }}>
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 10 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 10 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(10)}
                        >
                            Servicable Locations
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 11 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 11 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(11)}
                        >
                            Add New Locations
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 12 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 12 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(12)}
                        >
                            God's View
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 13 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 13 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(13)}
                        >
                            Heat View
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 14 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 14 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(14)}
                        >
                            Reports
                        </div>
                    </Link>
                    <div className="nnnvnfnvf">
                        SETTINGS AND UTILITIES
                    </div>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 15 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 15 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(15)}
                        >
                            General
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 16 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 16 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(16)}
                        >
                            Currency
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 17 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 17 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(17)}
                        >
                            Send Push Notification
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 18 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 18 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(18)}
                        >
                            Documents
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 19 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 19 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(19)}
                        >
                            Vehicle Make
                        </div>
                    </Link>
                    <Link style={{ textDecoration: 'none', color: "black" }}  >
                        <div 
                            className="dnjnkfjk" 
                            style={{
                                backgroundColor: selectedIndex === 20 ? 'rgb(77, 77, 221)' : 'white',
                                color: selectedIndex === 20 ? 'white' : 'black'
                            }}
                            onClick={() => handleOptionClick(20)}
                        >
                            Vehicle Model
                        </div>
                    </Link>
                </div>
                <div className="dnjfnjn">
                {
                    selectedIndex==0?<Dashboard/>:selectedIndex==4?<Drivers/>:selectedIndex==3?<Ridepage/>:selectedIndex==7?<Cab_category_page/>:selectedIndex==5?<Riders/>:selectedIndex==9?<Driverapproval/>:selectedIndex==11?<Addlocations/>:selectedIndex==10?<Servicable_Locations/>:selectedIndex==13?<Heatview/>:<></>
                }
                </div>
            </div>
        </div>
    )
}
