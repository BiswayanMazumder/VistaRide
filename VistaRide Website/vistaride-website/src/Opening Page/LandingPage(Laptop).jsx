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
            </div>
        </div>
    )
}
