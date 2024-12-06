import React, { useEffect, useState } from 'react';
import { onAuthStateChanged, getAuth } from "firebase/auth";
import { doc, getDoc, getFirestore } from "firebase/firestore";
import { initializeApp } from "firebase/app";
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

export default function Mytripslaptop() {
    const [userName, setUserName] = useState(null);
    const [userPfp, setUserPfp] = useState(null);
    const [user, setUser] = useState('');
    const [tripid, setTripid] = useState([]);
    const [carcatergory, setCarcategory] = useState([]);
    const [startlocation, setStartlocation] = useState([]);
    const [endlocation, setendlocation] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [ridecancelled, setRidecancelled] = useState([]);
    const [picklat, setPicklat] = useState([]);
    const [picklng, setPicklng] = useState([]);
    const [droplat, setDroplat] = useState([]);
    const [droplng, setDroplng] = useState([]);
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
            }
        };

        const fetchRideDetails = async () => {
            try {
                const docRef = doc(db, 'Booking IDs', user);
                const docSnap = await getDoc(docRef);

                if (docSnap.exists()) {
                    const tripIds = docSnap.data()['IDs'];
                    setTripid(tripIds);

                    const carCategories = [];
                    const startLocations = [];
                    const Endlocations = [];
                    const Ridecancelled = [];
                    const pickupLats = [];
                    const pickupLons = [];
                    const dropLats = [];
                    const dropLons = [];
                    for (const trip of tripIds) {
                        const rideDocRef = doc(db, 'Ride Details', trip);
                        const rideDocSnap = await getDoc(rideDocRef);

                        if (rideDocSnap.exists()) {
                            carCategories.push(rideDocSnap.data()['Cab Category']);
                            startLocations.push(rideDocSnap.data()['Pickup Location']);
                            Endlocations.push(rideDocSnap.data()['Drop Location']);
                            Ridecancelled.push(rideDocSnap.data()['Ride Cancelled'] ?? false);
                            pickupLats.push(rideDocSnap.data()['Pickup Latitude']);
                            pickupLons.push(rideDocSnap.data()['Pick Longitude']);
                            dropLats.push(rideDocSnap.data()['Drop Latitude']);
                            dropLons.push(rideDocSnap.data()['Drop Longitude']);
                        }
                    }
                    console.log(Ridecancelled);
                    setCarcategory(carCategories);
                    setStartlocation(startLocations);
                    setendlocation(Endlocations);
                    setRidecancelled(Ridecancelled);
                    setPicklat(pickupLats);
                    setPicklng(pickupLons);
                    setDroplat(dropLats);
                    setDroplng(dropLons);
                }

            } catch (err) {
                setError(`Error fetching ride details: ${err.message}`);
            }
        };

        Promise.all([fetchUserDetails(), fetchRideDetails()])
            .finally(() => setLoading(false));
    }, [user]);

    useEffect(() => {
        document.title = 'Request a Ride with VistaRide';
    }, []);
    return (
        <div className='webbody'>
            <div className="ehfjfv" style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Link to={'/go/home'}>
                    <div className="hfejfw">
                        <svg width="100" height="30" xmlns="http://www.w3.org/2000/svg">
                            <rect width="100" height="30" fill="black" rx="5"></rect>
                            <text x="50%" y="50%" font-family="'Lobster', cursive" font-size="21" fill="white" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">
                                VistaRide
                            </text>
                        </svg>
                    </div>
                </Link>
                <div className="hfejfw" style={{ right: '100px', position: 'absolute', flexDirection: 'row', gap: '20px' }}>
                    <Link style={{ textDecoration: 'none', color: "white" }}>
                        <div className="dbvbvdhna" style={{ fontWeight: '600' }}>My Trips</div>
                    </Link>
                    <div className="dbvbvdhn">{userName}</div>
                    <div className="dbvbvdhn">
                        <img
                            src={userPfp}
                            alt=""
                            height="45px"
                            width="45px"
                            style={{ borderRadius: '50%' }}
                        />
                    </div>
                </div>
            </div>
            {loading ? (
                <div style={{
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center',
                    height: 'calc(100vh - 60px)', // Adjust height to account for navigation bar
                }}>
                    <div style={{
                        width: '80px',
                        height: '80px',
                        border: '8px solid #f3f3f3',
                        borderTop: '8px solid #3498db',
                        borderRadius: '50%',
                        animation: 'spin 1s linear infinite',
                    }}></div>
                    <style>{`
                        @keyframes spin {
                            0% { transform: rotate(0deg); }
                            100% { transform: rotate(360deg); }
                        }
                    `}</style>
                </div>
            ) : (<div className="dnjfndndjn">
                <div className="rnrnv">
                    <img src="https://d3i4yxtzktqr9n.cloudfront.net/riders-web-v2/853ebe0d95a62aca.svg" alt="" width={'100%'} style={{ borderRadius: '10px' }} />
                    <div className="dnvjnv">Past</div>
                    <div className="rnjnfjvn" style={{ marginTop: '40px' }}>
                        {tripid.map((trip, index) => (
                            <Link key={trip} style={{ textDecoration: 'none', color: 'black' }}>

                                <div className="tripdetails" onClick={() => {
                                    localStorage.setItem('Pickup Location', startlocation[index]);
                                    localStorage.setItem('Drop Location', endlocation[index]);
                                    localStorage.setItem('Pickup Latitude', picklat[index]);
                                    localStorage.setItem('Pickup Longitude', picklng[index]);
                                    localStorage.setItem('Drop Latitude', droplat[index]);
                                    localStorage.setItem('Drop Longitude', droplng[index]);
                                    localStorage.setItem('Car Category', carcatergory[index]);
                                    localStorage.setItem('Ride Cancelled', ridecancelled[index]);
                                    //  location.setItem('Driver Name',driver[index]);

                                }}>
                                    <div style={{ fontWeight: '400', color: 'red', margin: '30px', marginTop: '10px', marginBottom: '0px' }}>
                                        {ridecancelled[index] ? 'Cancelled' : ''}
                                    </div>
                                    <div style={{ fontWeight: '500', color: 'black', margin: '30px', marginTop: '10px' }}>
                                        {carcatergory[index]} from
                                    </div>
                                    <div style={{ fontWeight: '500', color: 'black', margin: '30px', marginBottom: '0px' }}>
                                        {startlocation[index]}
                                    </div>
                                    <div style={{ fontWeight: '300', color: 'grey', margin: '30px', marginTop: '10px', marginBottom: '10px' }}>
                                        to
                                    </div>
                                    <div style={{ fontWeight: '500', color: 'black', margin: '30px', marginTop: '0px', marginBottom: '20px' }}>
                                        {endlocation[index]}
                                    </div>
                                </div>
                            </Link>
                        ))}
                    </div>
                </div>
            </div>)}
        </div>
    );
}
