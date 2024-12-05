import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { GoogleMap, LoadScript, Marker, Polyline } from '@react-google-maps/api';
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth, GoogleAuthProvider, onAuthStateChanged, signInWithPopup } from "firebase/auth";

const provider = new GoogleAuthProvider();
const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:0f8c6be4228dba901ea368",
    measurementId: "G-ZFRR1BZQFV"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
// Get Auth instance and Google provider
const auth = getAuth(app);
const googleProvider = new GoogleAuthProvider();
const defaultLatLng = { lat: 22.5660201, lng: 88.3630783 };
export default function LandingPageMobile() {
    const [user, setUser] = useState(null);
    const [error, setError] = useState(null);
    useEffect(() => {
        onAuthStateChanged(auth, (user) => {
            if (user) {
              window.location.replace('/go/home');
              const uid = user.uid;
              // ...
            } else {
              // User is signed out
              // ...
            }
          });
    })
    const handleLogin = async () => {
        // try {
        //     const result = await signInWithPopup(auth, googleProvider);
        //     const user = result.user;
        //     setUser(user);
        //     window.location.replace('/go/home');
        // } catch (err) {
        //     setError(err.message);
        // }
    };
    const [pickupLocation, setPickupLocation] = useState('');
    const [dropLocation, setDropLocation] = useState('');
    const [pickupSuggestions, setPickupSuggestions] = useState([]);
    const [dropSuggestions, setDropSuggestions] = useState([]);
    const [selectedPickupLocation, setSelectedPickupLocation] = useState(defaultLatLng);
    const [selectedDropLocation, setSelectedDropLocation] = useState(null);
    const [mapContainerStyle, setMapContainerStyle] = useState({
        width: '40vw',
        height: '400px',
    });
    const [directions, setDirections] = useState(null); // To hold directions result

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
        const handleResize = () => {
            setMapContainerStyle({
                width: '576px',
                height: '576px',
            });
        };

        window.addEventListener('resize', handleResize);
        handleResize();

        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, []);

    useEffect(() => {
        // If both locations are selected, fetch directions to draw polyline
        if (selectedPickupLocation && selectedDropLocation) {
            const directionsService = new window.google.maps.DirectionsService();

            const request = {
                origin: selectedPickupLocation,
                destination: selectedDropLocation,
                travelMode: window.google.maps.TravelMode.DRIVING, // You can change this to WALKING, BICYCLING, etc.
            };

            directionsService.route(request, (result, status) => {
                if (status === window.google.maps.DirectionsStatus.OK) {
                    console.log("Directions response:", result); // Log the directions response
                    setDirections(result); // Save the directions result
                } else {
                    console.error("Directions request failed:", status); // Log error if request fails
                }
            });
        }
    }, [selectedPickupLocation, selectedDropLocation]);

    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };

    // Calculate the center between pickup and drop for map centering
    const mapCenter = selectedDropLocation
        ? {
            lat: (selectedPickupLocation.lat + selectedDropLocation.lat) / 2,
            lng: (selectedPickupLocation.lng + selectedDropLocation.lng) / 2,
        }
        : selectedPickupLocation || defaultLatLng;

    // Add console logs to debug the pickup location
    useEffect(() => {
        console.log("Selected Pickup Location:", selectedPickupLocation);
    }, [selectedPickupLocation]);
    return (
        <div className='webbody'>
            <div className="jnnvfkvfk">
                <div className="hvfnvn">
                    <div className="mdnjvn">
                    <svg width="100" height="30" xmlns="http://www.w3.org/2000/svg"><rect width="100" height="30" fill="black" rx="5"></rect><text x="50%" y="50%" font-family="'Lobster', cursive" font-size="21" fill="white" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">VistaRide</text></svg>
                    </div>
                    <Link style={{ textDecoration: 'none', color: 'white' }} onClick={handleLogin}>
                        <div className="eefebfs" style={{ padding: "30px" }}>Log in</div>
                    </Link>
                </div>
                <div className="ndjvnjd">
                    <div className="ehfbehfb">
                        Go anywhere with VistaRide
                    </div>
                    <div className="ehfbehfbd">
                        Request a ride,hop in,and go.
                    </div>
                    <div className="njnv" style={{ position: 'relative' }}>
                        <input
                            type="text"
                            placeholder="Pickup Location"
                            className="ehbfhebfe"
                            value={pickupLocation}
                            onChange={handlePickupInputChange}
                        />
                        {pickupSuggestions.length > 0 && (
                            <ul
                                style={{
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
                                    top: '100%', // Aligns right below the input
                                    left: '0',
                                    width: '90%', // Reduced width (adjust percentage or set px value)
                                }}
                            >
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

                    <div className="njnv" style={{ marginTop: "20px", position: 'relative' }}>
                        <input
                            type="text"
                            placeholder="Drop Location"
                            className="ehbfhebfe"
                            value={dropLocation}
                            onChange={handleDropInputChange}
                        />
                        {dropSuggestions.length > 0 && (
                            <ul
                                style={{
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
                                    width: '90%',
                                }}
                            >
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

                    <Link style={{ textDecoration: 'none', color: 'white' }}>
                        <div className="jffnrn" style={{ backgroundColor: 'white', marginLeft: '30px', marginTop: "25px", color: 'black' }}>See prices</div>
                    </Link>
                    <div className="djvnj" style={{ padding: "30px" }}>
                        <img src="https://www.uber-assets.com/image/upload/f_auto,q_auto:eco,c_fill,h_690,w_552/v1684852612/assets/ba/4947c1-b862-400e-9f00-668f4926a4a2/original/Ride-with-Uber.png" alt="" width={"100%"} height={"40%"} />
                    </div>
                </div>
                <div className="dnffnf">
                    <div className="jejfr">
                        Drive when you want, make what you need
                    </div>
                    <div className="jjndjvnfv">
                        Make money on your schedule with deliveries or rides—or both. You can use your own car or choose a rental through VistaRide.
                    </div>
                    <div className="dndjvnj">
                        <Link style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="jffnrn">
                                Get Started
                            </div>
                        </Link>
                    </div>
                    <div className="djvnj" style={{ padding: "30px" }}>
                        <img src="https://www.uber-assets.com/image/upload/f_auto,q_auto:eco,c_fill,h_552,w_552/v1684855112/assets/96/4dd3d1-94e7-481e-b28c-08d59353b9e0/original/earner-illustra.png" alt="" width={"100%"} height={"40%"} />
                    </div>
                </div>
                <br /><br />
                <div className="jejfr">
                    The VistaRide you know, reimagined for business
                </div>
                <div className="jjndjvnfv">
                VistaRide for Business is a platform for managing global rides and meals, and local deliveries, for companies of any size.
                </div>
                <div className="dndjvnj">
                    <Link style={{ textDecoration: 'none', color: 'white' }}>
                        <div className="jffnrn">
                            Get Started
                        </div>
                    </Link>
                </div>
                <div className="djvnj" style={{ padding: "30px" }}>
                    <img src="https://www.uber-assets.com/image/upload/f_auto,q_auto:eco,c_fill,h_552,w_552/v1684887108/assets/76/baf1ea-385a-408c-846b-59211086196c/original/u4b-square.png" alt="" width={"100%"} height={"40%"} />
                </div>
                <div className="jejfr">
                    Make money by renting out your car
                </div>
                <div className="jjndjvnfv">
                    Connect with thousands of drivers and earn more per week with VistaRide's free fleet management tools.
                </div>
                <div className="dndjvnj">
                    <Link style={{ textDecoration: 'none', color: 'white' }}>
                        <div className="jffnrn">
                            Get Started
                        </div>
                    </Link>
                </div>
                <div className="djvnj" style={{ padding: "30px" }}>
                    <img src="https://www.uber-assets.com/image/upload/f_auto,q_auto:eco,c_fill,h_552,w_552/v1696243819/assets/18/34e6fd-33e3-4c95-ad7a-f484a8c812d7/original/fleet-management.jpg" alt="" width={"100%"} height={"40%"} />
                </div>
            </div>
        </div>
    )
}
