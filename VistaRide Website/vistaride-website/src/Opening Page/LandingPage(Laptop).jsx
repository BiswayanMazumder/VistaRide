import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';

// Default coordinates (latitude, longitude)
const defaultLatLng = { lat: 22.5660201, lng: 88.3630783 };
export default function LandingPage_Laptop() {
    const [mapContainerStyle, setMapContainerStyle] = useState({
        width: '40vw', // Set width to 40% of the viewport width
        height: '400px', // You can adjust the height as needed
    });

    useEffect(() => {
        // Dynamically set the map container height based on window size or any other logic
        const handleResize = () => {
            setMapContainerStyle({
                width: '576px', // Keeps the width at 40% of the viewport width
                height: '576px', // height remains fixed or dynamic
            });
        };

        window.addEventListener('resize', handleResize);
        handleResize(); // Call it once to ensure correct initial sizing

        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, []);
    const mapOptions = {
        zoomControl: false, // Disable zoom control
        mapTypeControl: false, // Disable map type control (satellite, street view, etc.)
        streetViewControl: false, // Disable street view control
        fullscreenControl: false, // Disable fullscreen control
    };
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
                    <div className="enhfnjn">
                        <div className="jnjvn">
                            Go anywhere with<br />VistaRide
                        </div>
                        <div className="jnjvndd" style={{ marginTop: '30px' }}>
                            <input type="text" className='ebfbebfeh' placeholder=' Pickup location' />
                        </div>
                        <div className="jnjvndd" style={{ marginTop: '20px' }}>
                            <input type="text" className='ebfbebfeh' placeholder=' Dropoff location' />
                        </div>
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="jffnrn">
                                See prices
                            </div>
                        </Link>
                    </div>
                    <div className="mapssection">
                        <LoadScript
                            googleMapsApiKey='Google_Maps_API_KEY'
                        >
                            <GoogleMap
                                mapContainerStyle={mapContainerStyle}
                                center={defaultLatLng}
                                zoom={12}
                                options={mapOptions}
                            >
                                <Marker position={defaultLatLng} />
                            </GoogleMap>
                        </LoadScript>
                    </div>
                </div>
                <div className="njnjnnfv">
                    <img src="https://www.uber-assets.com/image/upload/f_auto,q_auto:eco,c_fill,h_576,w_576/v1684855112/assets/96/4dd3d1-94e7-481e-b28c-08d59353b9e0/original/earner-illustra.png" alt="" height={576} width={576} />
                    <div className="jdnfjkjk">
                        <div className="nfvn">
                            Drive when you<br />want, make what<br /> you need
                        </div>
                        <div className="mdnfjdnm">
                            Make money on your schedule with deliveries or rides—or<br />both. You can use your own car or choose a rental<br />through VistaRide.
                        </div>
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="jffnrn">
                                Get Started
                            </div>
                        </Link>
                    </div>
                </div>
                <div className="njnjnnfv">
                     <div className="jdnfjkjk">
                        <div className="nfvn">
                        The VistaRide you<br />know, reimagined<br />for business
                        </div>
                        <div className="mdnfjdnm">
                        VistaRide for Business is a platform for managing global rides and<br/>and local deliveries, for companies of any size.
                        </div>
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="jffnrn">
                                Get Started
                            </div>
                        </Link>
                    </div>
                    <img src="https://www.uber-assets.com/image/upload/f_auto,q_auto:eco,c_fill,h_576,w_576/v1684887108/assets/76/baf1ea-385a-408c-846b-59211086196c/original/u4b-square.png" alt="" height={576} width={576} />
                </div>
                <div className="njnjnnfv">
                    <img src="https://www.uber-assets.com/image/upload/f_auto,q_auto:eco,c_fill,h_576,w_576/v1696243819/assets/18/34e6fd-33e3-4c95-ad7a-f484a8c812d7/original/fleet-management.jpg" alt="" height={576} width={576} />
                    <div className="jdnfjkjk">
                        <div className="nfvn">
                        Make money by renting out<br/>your car
                        </div>
                        <div className="mdnfjdnm">
                        Connect with thousands of drivers and earn more per week<br/>with VistaRide's free fleet management tools.
                        </div>
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="jffnrn">
                                Get Started
                            </div>
                        </Link>
                    </div>
                    <br /><br />
                </div>
            </div>
        </div>
    )
}
