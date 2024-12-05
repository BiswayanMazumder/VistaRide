import React, { useEffect, useRef, useState } from 'react';
import { onAuthStateChanged, getAuth, signOut } from "firebase/auth";
import { arrayRemove, arrayUnion, collection, deleteField, doc, FieldValue, getDoc, getFirestore, onSnapshot, serverTimestamp, setDoc, updateDoc } from "firebase/firestore";
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
    const [bookingstarted, setbookingstarted] = useState(false);
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
    const [RideID, setRideID] = useState('');
    useEffect(() => {
        const fetchactiveride = async () => {
            try {
                let rideid = []; // Use `let` instead of `const` for reassignment
                const docRef = doc(db, "Booking IDs", user); // Ensure `db` and `user` are defined
                const docSnap = await getDoc(docRef);
                if (docSnap.exists()) {
                    rideid = docSnap.data().IDs; // Use `.data()` method and properly access fields
                }
                console.log('Ride ID:', rideid);
                for (var i = 0; i < rideid.length; i++) {
                    const RideRef = doc(db, "Ride Details", rideid[i].toString());
                    const docsnap = await getDoc(RideRef);
                    if (docsnap.exists()) {
                        if (docsnap.data()['Ride Accepted']) {
                            setRideID(rideid[i]);
                            window.location.replace(`/ride/${rideid[i]}`);
                        }
                    }
                }
                // console.log("Ride ID:", RideID);
                localStorage.setItem('Active Ride ID', RideID);

            } catch (error) {
                console.error("Error fetching active ride:", error);
            }
        };

        fetchactiveride();
    }, [db, user]);
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
    const writeRideDetailsToDB = async (rideId) => {
        const docRef = doc(db, "Booking IDs", user); // Define docRef outside of the try-catch block
        try {
            await updateDoc(docRef, {
                IDs: arrayUnion(rideId), // Append the rideId to the array
            });
            console.log("Document successfully updated!");
        } catch (error) {
            if (error.code === "not-found") {
                // If the document doesn't exist, create it with the initial array
                await setDoc(docRef, { IDs: [rideId] });
                console.log("Document created successfully!");
            } else {
                console.error("Error updating document: ", error);
            }
        }
    };
    const removeridfromdb = async (rideId) => {
        const docRef = doc(db, "Booking IDs", user); // Define docRef outside of the try-catch block
        await updateDoc(docRef, {
            IDs: arrayRemove(rideId), // Append the rideId to the array
        });
        console.log("Document successfully updated!");

    };
    const removeridfromdriver = async (rideId) => {
        for (let i = 0; i < drivers.length; i++) {
            // Get the document reference for the driver
            const docref = doc(db, "VistaRide Driver Details", drivers[i]);

            try {

                await updateDoc(docref, {
                    'Ride Requested': deleteField()  // This removes the field
                });
                console.log(`'Ride Requested' field removed for driver ${drivers[i]}`);
                // 10000 milliseconds = 10 seconds

            } catch (error) {
                console.error(`Error updating document for driver ${drivers[i]}:`, error);
            }
        }

    };

    const writeRideDetails = async (rideId) => {
        const randomotp = Math.floor(1000 + Math.random() * 9000);
        const docref = doc(db, "Ride Details", rideId.toString()); // Define docRef outside of the try-);
        let Fare = parseFloat(parseFloat(cabmultiplier[index]) * parseFloat(distanceAndTime.distance));

        // Ensure the Fare is sent as a double:
        Fare = Number(Fare.toFixed(2));
        try {
            // Write the initial ride details to Firestore
            await setDoc(docref, {
                'Cab Category': cabcategorynames[index],
                "Pickup Latitude": parseFloat(selectedPickupLocation.lat),
                "Pick Longitude": parseFloat(selectedPickupLocation.lng),
                "Drop Latitude": parseFloat(selectedDropLocation.lat),
                "Drop Longitude": parseFloat(selectedDropLocation.lng),
                "Booking ID": rideId,
                // "Booking Owner": user,
                "Ride OTP": randomotp,
                "Pickup Location": pickupLocation,
                "Drop Location": dropLocation,
                "Travel Distance": distanceAndTime.distance,
                "Travel Time": distanceAndTime.duration,
                "Booking Time": new Date(),
                'Driver ID': '',
                'Ride Verified': false,
                'Ride Accepted': false,
                'Ride Completed': false,
                "Fare": Fare,
            });

            // Set up a listener to monitor changes in the 'Ride Verified' field
            onSnapshot(docref, (docSnapshot) => {
                const data = docSnapshot.data();
                if (data && data['Ride Accepted'] === true) {
                    
                    // Redirect to the ride details page when 'Ride Verified' becomes true
                    window.location.replace(`/ride/${rideId}`);
                }
            });

        } catch (error) {
            console.error("Error writing ride details:", error);
        }
    };
    const handleLogout = async () => {
        try {
          await signOut(auth);
          console.log("User signed out successfully.");
          window.location.replace('/');
          // Optionally redirect or show a message to the user
        } catch (error) {
          console.error("Error signing out:", error);
        }
      };
    const sendriderequesttodriver = async (rideid) => {
        // Loop through each driver in the "drivers" array
        for (let i = 0; i < drivers.length; i++) {
            // Get the document reference for the driver
            const docref = doc(db, "VistaRide Driver Details", drivers[i]);

            try {
                // Update the document by adding 'Ride Requested' field
                await updateDoc(docref, {
                    'Ride Requested': rideid
                });

                console.log(`Ride requested for driver ${drivers[i]}`);

                // After 10 seconds, remove the 'Ride Requested' field
                setTimeout(async () => {
                    await updateDoc(docref, {
                        'Ride Requested': deleteField()  // This removes the field
                    });
                    console.log(`'Ride Requested' field removed for driver ${drivers[i]}`);
                }, 10000); // 10000 milliseconds = 10 seconds

            } catch (error) {
                console.error(`Error updating document for driver ${drivers[i]}:`, error);
            }
        }
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
                <div className="hfejfw">
                    <svg width="100" height="30" xmlns="http://www.w3.org/2000/svg"><rect width="100" height="30" fill="black" rx="5"></rect><text x="50%" y="50%" font-family="'Lobster', cursive" font-size="21" fill="white" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">VistaRide</text></svg>
                </div>
                <div className="hfejfw" style={{ right: '100px', position: 'absolute', flexDirection: 'row', gap: '20px' }}>
                    {loading ? (
                        <div></div>
                    ) : error ? (
                        <div style={{ color: 'red' }}>{error}</div>
                    ) : (
                        <>
                            <div className="dkf">{userName}</div>
                            <div className="jnjvndv" onClick={handleLogout}>
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
                        {
                            !bookingstarted ? <div className="fhbfnbjfn">
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
                            </div> : <div>
                                <div className="fgfhhggh">
                                    <img src={carcategoryimages[index]} alt="" style={{ marginLeft: '35px' }} />
                                </div>
                                <div className="ghgggfg">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" data-baseweb="icon"><title>search</title><path fill-rule="evenodd" clip-rule="evenodd" d="M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Zm5-2a5 5 0 1 1-10 0 5 5 0 0 1 10 0Z" fill="currentColor"></path></svg>
                                    {pickupLocation}
                                </div>
                                <div className="ghgggfg" style={{ marginTop: '50px' }}>
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" data-baseweb="icon"><title>search</title><path fill-rule="evenodd" clip-rule="evenodd" d="M14 10h-4v4h4v-4ZM7 7v10h10V7H7Z" fill="currentColor"></path></svg>
                                    {dropLocation}
                                </div>
                                <div className="ghgggfg" style={{ marginTop: '50px' }}>
                                    <img src='https://tb-static.uber.com/prod/wallet/icons/cash_3x.png' alt="" style={{ width: '30px', height: '30px' }} />
                                    ₹{cabmultiplier[index] * parseInt(distanceAndTime.distance)}
                                </div>
                                <Link style={{ textDecoration: 'none', color: 'white' }}>
                                    <div className="jjfnvjnf" style={{ backgroundColor: 'black', width: '90%', marginLeft: '5%', marginBottom: '20px', marginTop: '20px' }}
                                        onClick={() => {
                                            removeridfromdb(localStorage.getItem('Ride ID').toString());
                                            removeridfromdriver(localStorage.getItem('Ride ID').toString());
                                            setbookingstarted(false);
                                        }}
                                    >
                                        Cancel Request
                                    </div>
                                </Link>
                            </div>
                        }
                    </div>
                    {
                        bookingstarted ? <></> : (pickupLocation && dropLocation && distanceAndTime.distance) ? <div className="fbnbvfnbv" style={{ width: '30vw', overflowY: 'scroll' }}>
                            <div className="jrngjn">
                                <div className="jgnn">
                                    <img src='https://tb-static.uber.com/prod/wallet/icons/cash_3x.png' alt="" style={{ width: '30px', height: '30px', marginLeft: '10px' }} />
                                    <div className="jgjrufj" style={{ fontWeight: 'bolder' }}>
                                        Cash
                                    </div>
                                </div>
                                <div className="jjfnvjnf" style={{ backgroundColor: drivers.length > 0 ? 'black' : 'grey', cursor: drivers.length > 0 ? 'pointer' : 'not-allowed' }}
                                    onClick={() => {
                                        if (drivers.length > 0) {
                                            const random4DigitNumber = Math.floor(10000 + Math.random() * 90000);
                                            console.log(drivers)
                                            localStorage.setItem('Ride ID', random4DigitNumber);
                                            console.log(drivers);
                                            writeRideDetailsToDB(random4DigitNumber.toString());
                                            writeRideDetails(random4DigitNumber.toString());
                                            sendriderequesttodriver(random4DigitNumber.toString())
                                            setbookingstarted(true);
                                        }
                                    }}>
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
                                <div className="erhfrj" style={{ border: index === 0 ? '2px solid black' : 'white' }} onClick={() => {
                                    fetchDrivers(cabcategorynames[0])
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
                                <div className="erhfrj" style={{ border: index === 2 ? '2px solid black' : 'white' }} onClick={() => {
                                    setindex(2)
                                    fetchDrivers(cabcategorynames[2])
                                }}>
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
                                <div className="erhfrj" style={{ marginBottom: '110px', border: index === 3 ? '2px solid black' : 'white', marginTop: '20px' }} onClick={() => {
                                    setindex(3)
                                    fetchDrivers(cabcategorynames[3])
                                }}>
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
                                    url: "https://d1a3f4spazzrp4.cloudfront.net/car-types/map70px/map-blue-uberx.png",
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
