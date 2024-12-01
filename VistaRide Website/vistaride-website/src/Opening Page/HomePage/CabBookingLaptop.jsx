import React, { useEffect, useState } from 'react';
import { onAuthStateChanged, getAuth } from "firebase/auth";
import { doc, FieldValue, getDoc, getFirestore, serverTimestamp } from "firebase/firestore";
import { initializeApp } from "firebase/app";
import { GoogleMap, LoadScript, Marker, Polyline } from '@react-google-maps/api';
import { Link } from 'react-router-dom';

const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:0f8c6be4228dba901ea368",
    measurementId: "G-ZFRR1BZQFV",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
const defaultLatLng = { lat: 22.5660201, lng: 88.3630783 };

export default function CabBookingLaptop() {
    const cabmultiplier = [36, 40, 65, 15];
    const [user, setUser] = useState('');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [userName, setUserName] = useState(null);
    const [userPfp, setUserPfp] = useState(null);

    const [pickupLocation, setPickupLocation] = useState('');
    const [dropLocation, setDropLocation] = useState('');
    const [pickupSuggestions, setPickupSuggestions] = useState([]);
    const [dropSuggestions, setDropSuggestions] = useState([]);
    const [selectedPickupLocation, setSelectedPickupLocation] = useState(defaultLatLng);
    const [selectedDropLocation, setSelectedDropLocation] = useState(null);
    const [mapContainerStyle, setMapContainerStyle] = useState({
        width: '100vw',
        height: '89vh',
    });
    const [directions, setDirections] = useState(null);
    const [distanceAndTime, setDistanceAndTime] = useState({ distance: '', duration: '' });

    const handlePickupInputChange = (e) => {
        const value = e.target.value;
        setPickupLocation(value);

        if (value.length > 2) {
            const service = new window.google.maps.places.AutocompleteService();
            service.getPlacePredictions(
                { input: value },
                (predictions, status) => {
                    if (status === window.google.maps.places.PlacesServiceStatus.OK) {
                        setPickupSuggestions(predictions);
                    }
                }
            );
        } else {
            setPickupSuggestions([]);
        }
    };

    const handleDropInputChange = (e) => {
        const value = e.target.value;
        setDropLocation(value);

        if (value.length > 2) {
            const service = new window.google.maps.places.AutocompleteService();
            service.getPlacePredictions(
                { input: value },
                (predictions, status) => {
                    if (status === window.google.maps.places.PlacesServiceStatus.OK) {
                        setDropSuggestions(predictions);
                    }
                }
            );
        } else {
            setDropSuggestions([]);
        }
    };

    const handleSuggestionClick = (placeId, type) => {
        const service = new window.google.maps.places.PlacesService(document.createElement('div'));

        service.getDetails({ placeId }, (place, status) => {
            if (status === window.google.maps.places.PlacesServiceStatus.OK) {
                const location = {
                    lat: place.geometry.location.lat(),
                    lng: place.geometry.location.lng(),
                };

                if (type === 'pickup') {
                    setSelectedPickupLocation(location);
                    setPickupLocation(place.formatted_address);
                    setPickupSuggestions([]);
                } else if (type === 'drop') {
                    setSelectedDropLocation(location);
                    setDropLocation(place.formatted_address);
                    setDropSuggestions([]);
                }
            }
        });
    };

    useEffect(() => {
        setDirections(null);

        if (selectedPickupLocation && selectedDropLocation) {
            const directionsService = new window.google.maps.DirectionsService();

            const request = {
                origin: selectedPickupLocation,
                destination: selectedDropLocation,
                travelMode: window.google.maps.TravelMode.DRIVING,
            };

            directionsService.route(request, (result, status) => {
                if (status === window.google.maps.DirectionsStatus.OK) {
                    console.log("Directions response:", result);
                    setDirections(result);
                    const distance = result.routes[0].legs[0].distance.text;
                    const duration = result.routes[0].legs[0].duration.text;

                    console.log(`Distance: ${distance}, Duration: ${duration}`);
                    setDistanceAndTime({ distance, duration });
                } else {
                    console.error("Directions request failed:", status);
                }
            });
        }
    }, [selectedPickupLocation, selectedDropLocation]);

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
            if (currentUser) {
                setUser(currentUser.uid);
            } else {
                window.location.replace('/');
            }
        });

        return () => unsubscribe();
    }, []);

    useEffect(() => {
        if (!user) return;

        const fetchUserDetails = async () => {
            setLoading(true);
            try {
                const docRef = doc(db, "VistaRide User Details", user);
                const docSnap = await getDoc(docRef);

                if (docSnap.exists()) {
                    setUserName(docSnap.data()['User Name']);
                    setUserPfp(docSnap.data()['Profile Picture']);
                } else {
                    setError("No user data found.");
                }
            } catch (err) {
                setError(`Error fetching user data: ${err.message}`);
            } finally {
                setLoading(false);
            }
        };

        fetchUserDetails();
    }, [user]);
    useEffect(() => {
        document.title = 'Request a Ride with VistaRide';
    }, []);

    useEffect(() => {
        if ("geolocation" in navigator) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const currentLocation = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                    };
                    setSelectedPickupLocation(currentLocation);
                },
                (error) => {
                    console.error("Error fetching current location:", error);
                }
            );
        } else {
            console.error("Geolocation not supported by this browser.");
        }
    }, []);

    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };

    const mapCenter = selectedDropLocation
        ? {
            lat: (selectedPickupLocation.lat + selectedDropLocation.lat) / 2,
            lng: (selectedPickupLocation.lng + selectedDropLocation.lng) / 2,
        }
        : selectedPickupLocation || defaultLatLng;

    return (
        <div className="webbody">
            <div className="ehfjfv" style={{ display: 'flex', justifyContent: 'space-between' }}>
                <div className="hfejfw">VistaRide</div>
                <div className="hfejfw" style={{ right: '100px', position: 'absolute', flexDirection: 'row', gap: '20px' }}>
                    {loading ? (
                        <div></div>
                    ) : error ? (
                        <div style={{ color: 'red' }}>{error}</div>
                    ) : (
                        <>
                            <div className="dkf">{userName}</div>
                            <div className="jnjvndv">
                                <img
                                    src={userPfp}
                                    alt=""
                                    height="45px"
                                    width="45px"
                                    style={{ borderRadius: '50%' }}
                                />
                            </div>
                        </>
                    )}
                </div>
            </div>
            <div className="ejhfjhfd">
                <div className="djhfndj" style={{display: 'flex', flexDirection: 'row'}}>
                    <div className="fbnbvfnbv">
                        <div className="fhbfnbjfn">
                            <div className="mdnvjnv" style={{ fontSize: '30px', fontWeight: 'bold', display: 'flex', justifyContent: 'start', alignItems: 'start', flexDirection: 'row' }}>
                                Find a trip
                            </div>
                            <div className="mdnvjnv" style={{ position: 'relative' }}>
                                <input
                                    type="text"
                                    className="ebfbebfeh"
                                    placeholder="Pickup location"
                                    value={pickupLocation}
                                    onChange={handlePickupInputChange}
                                />
                                {pickupSuggestions.length > 0 && (
                                    <ul style={{
                                        listStyleType: 'none',
                                        padding: '0',
                                        margin: '0',
                                        border: '1px solid #ccc',
                                        borderRadius: '4px',
                                        maxHeight: '150px',
                                        overflowY: 'auto',
                                        backgroundColor: '#fff',
                                        position: 'absolute',
                                        top: '100%',
                                        left: '0',
                                        right: '0',
                                        zIndex: 1000,
                                    }}>
                                        {pickupSuggestions.map((suggestion) => (
                                            <li
                                                key={suggestion.place_id}
                                                style={{
                                                    padding: '6px 10px',
                                                    cursor: 'pointer',
                                                    borderBottom: '1px solid #f0f0f0',
                                                    fontSize: '16px',
                                                    lineHeight: '1.4',
                                                }}
                                                onClick={() => handleSuggestionClick(suggestion.place_id, 'pickup')}
                                            >
                                                {suggestion.description}
                                            </li>
                                        ))}
                                    </ul>
                                )}
                            </div>

                            <div className="mdnvjnv" style={{ position: 'relative' }}>
                                <input
                                    type="text"
                                    className="ebfbebfeh"
                                    placeholder="Dropoff location"
                                    value={dropLocation}
                                    onChange={handleDropInputChange}
                                />
                                {dropSuggestions.length > 0 && (
                                    <ul style={{
                                        listStyleType: 'none',
                                        padding: '0',
                                        margin: '0',
                                        border: '1px solid #ccc',
                                        borderRadius: '4px',
                                        maxHeight: '150px',
                                        overflowY: 'auto',
                                        backgroundColor: '#fff',
                                        zIndex: 1000,
                                        position: 'absolute',
                                        top: '100%',
                                        left: '0',
                                        right: '0',
                                    }}>
                                        {dropSuggestions.map((suggestion) => (
                                            <li
                                                key={suggestion.place_id}
                                                style={{
                                                    padding: '6px 10px',
                                                    cursor: 'pointer',
                                                    borderBottom: '1px solid #f0f0f0',
                                                    fontSize: '16px',
                                                    lineHeight: '1.4',
                                                }}
                                                onClick={() => handleSuggestionClick(suggestion.place_id, 'drop')}
                                            >
                                                {suggestion.description}
                                            </li>
                                        ))}
                                    </ul>
                                )}
                            </div>

                            <div className="mdnvjnv">
                                <Link style={{ textDecoration: 'none', color: 'white' }}>
                                    <div
                                        className="jffnrn"
                                        style={{ backgroundColor: pickupLocation && dropLocation ? 'black' : 'grey' }}
                                        onClick={() => {

                                            if (distanceAndTime.distance && distanceAndTime.duration) {
                                                const random4DigitNumber = Math.floor(1000 + Math.random() * 9000);
                                                const randomotp = Math.floor(1000 + Math.random() * 9000);

                                                const bookingData = {
                                                    "Pickup Latitude": selectedPickupLocation.lat,
                                                    "Pickup Longitude": selectedPickupLocation.lng,
                                                    "Drop Latitude": selectedDropLocation.lat,
                                                    "Drop Longitude": selectedDropLocation.lng,
                                                    "Booking ID": random4DigitNumber,
                                                    "Booking Owner": user,
                                                    "Ride OTP": randomotp,
                                                    "Pickup Location": pickupLocation,
                                                    "Drop Location": dropLocation,
                                                    "Travel Distance": distanceAndTime.distance,
                                                    "Travel Time": distanceAndTime.duration,
                                                    "Booking Time": new Date(),  // Get current timestamp in ISO format
                                                    "Fare": cabmultiplier[0] * parseInt(distanceAndTime.distance)
                                                };

                                                // Log the booking data as a JSON string
                                                console.log(JSON.stringify(bookingData, null, 2)); // Pretty print JSON with 2 spaces indentation
                                            }

                                        }}
                                    >
                                        Get Started
                                    </div>

                                </Link>
                            </div>
                        </div>
                    </div>
                    {
                        (pickupLocation && dropLocation)?<div className="fbnbvfnbv" style={{width: '20vw'}}></div>:<></>
                    }
                </div>
                <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM" libraries={['places']}>
                    <GoogleMap
                        mapContainerStyle={mapContainerStyle}
                        center={mapCenter}
                        zoom={17}
                        options={{
                            zoomControl: true,
                            mapTypeControl: false,
                            streetViewControl: false,
                            fullscreenControl: false,
                        }}
                    >
                        {selectedPickupLocation && <Marker position={selectedPickupLocation} />}
                        {selectedDropLocation && <Marker position={selectedDropLocation} />}
                        {directions && directions.routes[0].overview_path && (
                            <Polyline
                                path={directions.routes[0].overview_path}
                                options={{
                                    strokeColor: 'black',
                                    strokeOpacity: 1,
                                    strokeWeight: 4,
                                }}
                            />
                        )}
                    </GoogleMap>
                </LoadScript>


            </div>
        </div>
    );
}
