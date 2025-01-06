import React, { useState } from 'react';
import { LoadScript, Autocomplete, GoogleMap, Circle } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { doc, getFirestore, setDoc } from 'firebase/firestore';
import { Link } from 'react-router-dom';

// Firebase config
const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:40aeb5d0434d67ca1ea368",
    measurementId: "G-9V0M9VQDGM"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

export default function Addlocations() {
    const [selectedCountry, setSelectedCountry] = useState('in'); // Default country is India ('in' is the ISO code)
    const [city, setCity] = useState('');
    const mapOptions = {
        zoomControl: false,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };
    const [coordinates, setCoordinates] = useState(null); // Store city coordinates
    const [autocomplete, setAutocomplete] = useState(null);
    const radius = 5000; // Radius in meters

    const handleCountryChange = (event) => {
        setSelectedCountry(event.target.value);
        setCity(''); // Reset city when country changes
        setCoordinates(null); // Clear map when country changes
    };

    const handleCitySelect = () => {
        if (autocomplete) {
            const place = autocomplete.getPlace();
            if (place.geometry) {
                const location = place.geometry.location;
                const lat = location.lat();
                const lng = location.lng();

                // console.log(`Selected City: ${place.name}, Latitude: ${lat}, Longitude: ${lng}`);

                setCity(place.name); // Set the city name
                setCoordinates(null); // Clear previous circle first
                setTimeout(() => {
                    const newCoordinates = { lat, lng };
                    setCoordinates(newCoordinates); // Set the new city coordinates after clearing the old one
                    logPointsInsideCircle(newCoordinates, radius); // Log points inside the circle
                }, 0);
            } else {
                console.error('No geometry information available for the selected place.');
            }
        }
    };

    const handleLoad = (autocompleteInstance) => {
        setAutocomplete(autocompleteInstance);
    };
    const [code, setCode] = useState("");
    const [pointslong, setpointslong] = useState([]);
    const [pointslat, setpointslat] = useState([]);
    const generateCode = async () => {
        const characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        let result = "";
        for (let i = 0; i < 4; i++) {
            const randomIndex = Math.floor(Math.random() * characters.length);
            result += characters[randomIndex];
        }
        setCode(result);
    };
    // Function to calculate and log points inside the circle
    const logPointsInsideCircle = async (center, radiusInMeters) => {
        const points = [];
        const pointslong = [];
        const pointslat = [];
        const step = 0.01; // Step size in degrees (~1.11 km per 0.01 degree latitude)
        await generateCode();
        // Convert radius to degrees (approximately)
        const radiusInDegrees = radiusInMeters / 111320; // 1 degree latitude ~ 111.32 km

        for (let lat = center.lat - radiusInDegrees; lat <= center.lat + radiusInDegrees; lat += step) {
            for (let lng = center.lng - radiusInDegrees; lng <= center.lng + radiusInDegrees; lng += step) {
                // Calculate the distance to the center
                const distance = haversineDistance(center, { lat, lng });
                if (distance <= radiusInMeters) {
                    pointslat.push(lat);
                    pointslong.push(lng);
                    // points.push({ lat, lng });
                }
            }
        }
        setpointslat(pointslat);
        setpointslong(pointslong);
        setunfilled(false);
    };

    // Haversine formula to calculate distance between two points
    const haversineDistance = (point1, point2) => {
        const toRadians = (deg) => (deg * Math.PI) / 180;
        const R = 6371000; // Radius of Earth in meters
        const dLat = toRadians(point2.lat - point1.lat);
        const dLng = toRadians(point2.lng - point1.lng);
        const lat1 = toRadians(point1.lat);
        const lat2 = toRadians(point2.lat);

        const a =
            Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.sin(dLng / 2) * Math.sin(dLng / 2) * Math.cos(lat1) * Math.cos(lat2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c; // Distance in meters
    };
    const [locationadded, setlocationadded] = useState(false);
    const [unfilled, setunfilled] = useState(true);
    const addlocation = async () => {
        // const data = {
        //     id: `loc_${code}`,
        //     Longitude_Range: pointslong,
        //     Latitude_Range: pointslat,
        //     citySelected: city,
        //     dateCreated: new Date().toISOString(), // ISO format for better readability and standardization
        // };

        // console.log(JSON.stringify(data, null, 2));
        try {
            const docRef = doc(db, 'Servicable Locations', `loc_${code}`);
            await setDoc(docRef, {
                id: `loc_${code}`,
                Longitude_Range: pointslong,
                Latitude_Range: pointslat,
                citySelected: city,
                dateCreated: new Date().toISOString(), // ISO format for better readability and standardization
            })
            setlocationadded(true);
        } catch (error) {
            setlocationadded(false);
        }
    };
    const [locationadd,setaddlocation]=useState(false);
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv" style={{width:'90%',display:'flex',flexDirection:'row',justifyContent:'space-between'}}>
                    {locationadd?'Add Locations':'Locations Added'}
                    <div className="djdbjf" style={{width:'120px',height:"40px",display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',background:'rgb(120, 120, 217)',borderRadius:'10px',color:'black',fontWeight:'500',fontSize:'15px'}} onClick={()=>setaddlocation(!locationadd)}>
                        {!locationadd?'Add Location':'Go Back'}
                    </div>
                </div>
                <div className="divider"></div>
                {locationadd?(<div className="knjfnbnf" style={{ display: 'flex', flexDirection: 'row', position: 'relative', width: '90%', height: '80%' }}>
                    <div className="ndvmnfmnf" style={{ position: 'relative', width: '40%', height: '100%', display: 'flex', flexDirection: 'column' }}>
                        <div className="nnfnjnfg" style={{ display: 'flex', flexDirection: 'row' }}>
                            Location Name
                            <div style={{ color: 'red', fontWeight: '600' }}>
                                *
                            </div>
                        </div>
                        <LoadScript
                            googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM"
                            libraries={['places']}
                        >
                            <Autocomplete
                                onLoad={handleLoad}
                                onPlaceChanged={handleCitySelect}
                                options={{
                                    types: ['(cities)'], // Restrict to city types
                                    componentRestrictions: { country: selectedCountry }, // Restrict to the selected country
                                }}
                            >
                                <input
                                    type="text"
                                    className='jjdhfhgfj'
                                    placeholder='Search Any Location'
                                    value={city}
                                    onChange={(e) => setCity(e.target.value)}
                                />
                            </Autocomplete>
                        </LoadScript>
                        <div className="nnfnjnfg" style={{ display: 'flex', flexDirection: 'row', marginTop: '30px' }}>
                            Country
                            <div style={{ color: 'red', fontWeight: '600' }}>
                                *
                            </div>
                        </div>
                        <select
                            className="jjdhfhgfj"
                            placeholder="Select Country"
                            value={selectedCountry}
                            onChange={handleCountryChange}
                        >
                            {[{ name: "Afghanistan", code: "af" },
                            { name: "Albania", code: "al" },
                            { name: "India", code: "in" },
                            { name: "United States", code: "us" },
                            { name: "United Kingdom", code: "gb" },
                                // Add other countries as needed
                            ].map((country, index) => (
                                <option key={index} value={country.code}>
                                    {country.name}
                                </option>
                            ))}
                        </select>
                        <div className="nnfnjnfg" style={{ display: 'flex', flexDirection: 'row', marginTop: '30px' }}>
                            Location Type
                            <div style={{ color: 'red', fontWeight: '600' }}>
                                *
                            </div>
                        </div>
                        <select
                            className="jjdhfhgfj"
                            placeholder="Select Option"
                        >
                            <option value="Pickup">Pickup</option>
                            <option value="Drop">Drop</option>
                        </select>
                        {unfilled ? <></> : (
                            <Link style={{ textDecoration: 'none', color: 'black' }}>
                                <div className="jfnvjnfb" style={{ textDecoration: 'none', color: 'black', width: '30%', borderRadius: '10px', marginTop: '30px', height: '40px', display: 'flex', flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }} onClick={locationadded ? null : addlocation}>
                                    <span style={{display:'flex',flexDirection:'row',fontSize:'13px',fontWeight:'500'}}>
                                        {locationadded?(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" >
                                            <path d="M7 10l3 3 7-7" stroke="green" stroke-width="2" fill="none" />
                                        </svg>):<></>}
                                        {locationadded ? 'Location Added' : 'Add Location'}
                                    </span>

                                </div>
                            </Link>
                        )}
                    </div>
                    <div className="ndvmnfmnf" style={{ position: 'relative', width: '60%', height: '95%' }}>
                        <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM" libraries={['places']} >
                            <GoogleMap
                                center={coordinates || { lat: 20.5937, lng: 78.9629 }} // Default to India if no city is selected
                                zoom={coordinates ? 12 : 4} // Zoom in if coordinates are available, else zoom out for country view
                                mapContainerStyle={{ width: '100%', height: '100%' }}
                                options={mapOptions}
                            >
                                {coordinates && (
                                    <Circle
                                        center={coordinates}
                                        radius={radius} // Radius in meters
                                        options={{
                                            fillColor: '#3498db',
                                            fillOpacity: 0.2,
                                            strokeColor: '#3498db',
                                            strokeOpacity: 0.8,
                                            strokeWeight: 2,
                                        }}
                                    />
                                )}
                            </GoogleMap>
                        </LoadScript>
                    </div>
                </div>):<></>}
            </div>
        </div>
    );
}
