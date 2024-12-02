import React, { useEffect, useRef, useState } from 'react';
import { onAuthStateChanged, getAuth } from "firebase/auth";
import { collection, doc, FieldValue, getDoc, getFirestore, onSnapshot, serverTimestamp } from "firebase/firestore";
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
    const mapRef = useRef(null);
    const [index, setindex] = useState(0);
    const cabmultiplier = [36, 40, 65, 15];
    const cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi'];
    const cabcategorydescription = [
        'Highly Discounted fare',
        'Spacious sedans, top drivers',
        'Spacious SUVs',
        ''];
    const carcategoryimages = [
        'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/Hatchback.png',
        'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/v1.1/UberX_v1.png',
        'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/package_UberXL_new_2022.png',
        'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png'
    ];
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

                    // Adjust the map bounds to fit the route
                    if (mapRef.current) {
                        const bounds = new window.google.maps.LatLngBounds();
                        result.routes[0].overview_path.forEach((latLng) => {
                            bounds.extend(latLng);
                        });
                        mapRef.current.fitBounds(bounds);
                    }
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
    const [drivers, setDrivers] = useState([]);
    const [markers, setMarkers] = useState([]);
    const isWithin15Km = (origin, destination) => {
        const R = 6371; // Radius of the Earth in km
        const dLat = (destination.lat - origin.lat) * (Math.PI / 180);
        const dLon = (destination.lng - origin.lng) * (Math.PI / 180);

        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(origin.lat * (Math.PI / 180)) * Math.cos(destination.lat * (Math.PI / 180)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);

        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        const distance = R * c; // Distance in km

        return distance <= 15; // Return true if within 15 km
    };

    // Fetch drivers when the selectedPickupLocation changes
    useEffect(() => {
        if (!selectedPickupLocation) return;

        const fetchDrivers = () => {
            const driversCollection = collection(db, "VistaRide Driver Details");

            // Set up a real-time listener on the driver details collection
            const unsubscribe = onSnapshot(driversCollection, (querySnapshot) => {
                const nearbyDrivers = [];
                const driverMarkers = [];

                querySnapshot.forEach((doc) => {
                    const driverData = doc.data();
                    const driverLocation = {
                        lat: parseFloat(driverData['Current Latitude']),  // Convert string to number
                        lng: parseFloat(driverData['Current Longitude']),
                    };
                    const driverAvailability = driverData['Driver Avaliable'];
                    const driverStatus = driverData['Driver Online'];

                    // Check if driver is online, available, and within 15 km
                    if (driverStatus && driverAvailability && isWithin15Km(selectedPickupLocation, driverLocation)) {
                        nearbyDrivers.push(doc.id); // Push driver UID if they are within range
                        driverMarkers.push({
                            id: doc.id,
                            position: driverLocation,
                        });
                    }
                });

                setDrivers(nearbyDrivers); // Update the state with the filtered list of drivers
                setMarkers(driverMarkers); // Update the state with the list of driver markers
                console.log("Nearby drivers (within 15 km):", nearbyDrivers);
            });

            // Cleanup the listener when component unmounts
            return () => unsubscribe();
        };

        fetchDrivers();
    }, [selectedPickupLocation]);
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
    const fetchDrivers = (carcategory) => {
        const driversCollection = collection(db, "VistaRide Driver Details");

        // Set up a real-time listener on the driver details collection
        const unsubscribe = onSnapshot(driversCollection, (querySnapshot) => {
            const nearbyDrivers = [];
            const driverMarkers = [];

            querySnapshot.forEach((doc) => {
                const driverData = doc.data();
                const driverLocation = {
                    lat: parseFloat(driverData['Current Latitude']),  // Convert string to number
                    lng: parseFloat(driverData['Current Longitude']),
                };
                const driverAvailability = driverData['Driver Avaliable'];
                const driverStatus = driverData['Driver Online'];

                // Check if driver is online, available, and within 15 km
                if (driverStatus && driverAvailability && isWithin15Km(selectedPickupLocation, driverLocation) && carcategory == driverData['Car Category']) {
                    nearbyDrivers.push(doc.id); // Push driver UID if they are within range
                    driverMarkers.push({
                        id: doc.id,
                        position: driverLocation,
                    });
                }
            });

            setDrivers(nearbyDrivers); // Update the state with the filtered list of drivers
            setMarkers(driverMarkers); // Update the state with the list of driver markers
            console.log("Nearby drivers (within 15 km):", nearbyDrivers);
        });

        // Cleanup the listener when component unmounts
        return () => unsubscribe();
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
                <div className="djhfndj" style={{ display: 'flex', flexDirection: 'row' }}>
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
                                    style={{ width: '350px' }}
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
                                    style={{ width: '350px' }}
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

                            {(pickupLocation && dropLocation) ? <></> : <div className="mdnvjnv">
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
                            </div>}
                        </div>
                    </div>
                    {
                        (pickupLocation && dropLocation && distanceAndTime.distance) ? <div className="fbnbvfnbv" style={{ width: '30vw', overflowY: 'scroll' }}>
                            <div className="jrngjn">
                                <div className="jgnn">
                                    <img src='https://tb-static.uber.com/prod/wallet/icons/cash_3x.png' alt="" style={{ width: '30px', height: '30px', marginLeft: '10px' }} />
                                    <div className="jgjrufj" style={{ fontWeight: 'bolder' }}>
                                        Cash
                                    </div>
                                </div>
                                <div className="jjfnvjnf">
                                    Request {cabcategorynames[index]}
                                </div>
                            </div>
                            <div className="jnjvnjv">
                                Choose a ride
                            </div>
                            <div className="jnjvnjv" style={{ fontSize: '20px', }}>
                                Recommended
                            </div>
                            <Link style={{ textDecoration: 'none', color: 'black' }}>
                                <div className="erhfrj" style={{ border: index === 0 ? '2px solid black' : 'white' }} onClick={() => {  fetchDrivers(cabcategorynames[0])
                                    setindex(0)
                                }
                                }>
                                    <div className="jjnvjfnv">
                                        <img src={carcategoryimages[0]} alt="" style={{ width: '100px', height: '100px' }} />
                                        <div className="jfnv">
                                            {cabcategorynames[0]}
                                            <div className="jnvn">
                                                {cabcategorydescription[0]}
                                            </div>
                                        </div>
                                    </div>
                                    <div className="erhbfr" style={{ fontWeight: 'bolder', marginRight: '20px', fontSize: '20px' }}>
                                        ₹{cabmultiplier[0] * parseInt(distanceAndTime.distance)}
                                    </div>
                                </div>
                            </Link>
                            <Link style={{ textDecoration: 'none', color: 'black' }}>
                                <div className="erhfrj" style={{ border: index === 1 ? '2px solid black' : 'white' }} onClick={() => {
                                    setindex(1)
                                    fetchDrivers(cabcategorynames[1])
                                }}>
                                    <div className="jjnvjfnv">
                                        <img src={carcategoryimages[1]} alt="" style={{ width: '100px', height: '100px' }} />
                                        <div className="jfnv">
                                            {cabcategorynames[1]}
                                            <div className="jnvn">
                                                {cabcategorydescription[1]}
                                            </div>
                                        </div>
                                    </div>
                                    <div className="erhbfr" style={{ fontWeight: 'bolder', marginRight: '20px', fontSize: '20px' }}>
                                        ₹{cabmultiplier[1] * parseInt(distanceAndTime.distance)}
                                    </div>
                                </div>
                            </Link>
                            <Link style={{ textDecoration: 'none', color: 'black' }}>
                                <div className="erhfrj" style={{ border: index === 2 ? '2px solid black' : 'white' }} onClick={() => {setindex(2)
                                fetchDrivers(cabcategorynames[2])}}>
                                    <div className="jjnvjfnv">
                                        <img src={carcategoryimages[2]} alt="" style={{ width: '100px', height: '100px' }} />
                                        <div className="jfnv">
                                            {cabcategorynames[2]}
                                            <div className="jnvn">
                                                {cabcategorydescription[2]}
                                            </div>
                                        </div>
                                    </div>
                                    <div className="erhbfr" style={{ fontWeight: 'bolder', marginRight: '20px', fontSize: '20px' }}>
                                        ₹{cabmultiplier[2] * parseInt(distanceAndTime.distance)}
                                    </div>
                                </div>
                            </Link>
                            <Link style={{ textDecoration: 'none', color: 'black' }}>
                                <div className="erhfrj" style={{ marginBottom: '110px', border: index === 3 ? '2px solid black' : 'white', marginTop: '20px' }} onClick={() => {setindex(3) 
                                fetchDrivers(cabcategorynames[3])}}>
                                    <div className="jjnvjfnv">
                                        <img src={carcategoryimages[3]} alt="" style={{ width: '100px', height: '100px' }} />
                                        <div className="jfnv">
                                            {cabcategorynames[3]}
                                            <div className="jnvn">
                                                {cabcategorydescription[3]}
                                            </div>
                                        </div>
                                    </div>
                                    <div className="erhbfr" style={{ fontWeight: 'bolder', marginRight: '20px', fontSize: '20px' }}>
                                        ₹{cabmultiplier[3] * parseInt(distanceAndTime.distance)}
                                    </div>
                                </div>
                            </Link>
                        </div> : <></>
                    }
                </div>
                <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM" libraries={['places']}>
                    <GoogleMap
                        mapContainerStyle={mapContainerStyle}
                        center={mapCenter}
                        zoom={17}
                        options={mapOptions}
                        onLoad={(map) => (mapRef.current = map)} // Store map instance in the ref
                    >
                        {selectedPickupLocation && <Marker position={selectedPickupLocation} />}
                        {selectedDropLocation && <Marker position={selectedDropLocation} />}

                        {/* Render markers for each nearby driver */}
                        {markers.map((driver) => (
                            <Marker
                                key={driver.id}
                                position={driver.position}
                                icon={{
                                    url: "https://d1a3f4spazzrp4.cloudfront.net/car-types/map70px/product/map-uberx.png",
                                    scaledSize: new window.google.maps.Size(40, 40), // Adjust marker size
                                }}
                            />
                        ))}

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
