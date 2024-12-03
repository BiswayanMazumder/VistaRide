import logo from './logo.svg';
import './App.css';
import {
  BrowserRouter,
  Routes,
  Route
} from 'react-router-dom';
import LandingPage from './Opening Page/LandingPage';
import Cabbookingpage from './Opening Page/HomePage/cabbookingpage';
import Activeride from './Active Ride Page/activeride';
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
      </Routes>
      <Routes>
        <Route path="/go/home" element={<Cabbookingpage />} />
      </Routes>
      <Routes>
        <Route path="/ride/:RideID" element={<Activeride />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
