

import React, { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/auth';
import toast from 'react-hot-toast';
import axios from 'axios';
import { BASE_URL } from '../utils/fetchData';

const Header = () => {
  const { auth, setAuth } = useAuth();
  const [isMobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const [showNotif, setShowNotif] = useState(false);
  const notifRef = useRef(null);

  useEffect(() => {
    if (auth?.user?.role === 1) {
      fetchNotifications();
      const interval = setInterval(fetchNotifications, 60000); // refresh every minute
      return () => clearInterval(interval);
    }
  }, [auth]);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (notifRef.current && !notifRef.current.contains(e.target)) {
        setShowNotif(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const fetchNotifications = async () => {
    try {
      const res = await axios.get(`${BASE_URL}/api/v1/fee/payment-reminders`);
      if (res.data?.success) {
        setNotifications(res.data.notifications || []);
      }
    } catch (err) {
      // silently fail
    }
  };

  const handleLogout = () => {
    setAuth({ ...auth, user: null, token: "" });
    localStorage.removeItem("auth");
    toast.success("Logout successfully");
  };

  return (
    <header className="bg-gradient-to-r from-blue-500 to-indigo-600 shadow-md py-4 sticky top-0 z-50">
      <div className="container mx-auto px-6 flex justify-between items-center">
        {/* Logo (Stylized Text) */}
        <Link to="/" className="flex items-center space-x-2">
          <span className="text-3xl sm:text-4xl font-extrabold text-yellow-400 tracking-widest">
            Force<span className="text-white">Gym</span>
          </span>
        </Link>

        {/* Hamburger Menu for Mobile */}
        <button
          className="lg:hidden text-white focus:outline-none"
          onClick={() => setMobileMenuOpen(!isMobileMenuOpen)}
        >
          <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16m-7 6h7" />
          </svg>
        </button>

        {/* Navigation Links */}
        <nav className="hidden lg:flex space-x-8 items-center">
          <ul className="flex space-x-6 text-lg">
            <li>
              <Link to="/" className="text-white hover:text-yellow-400 transition-all duration-300">
                Home
              </Link>
            </li>
            <li>
              <Link to="/exercise" className="text-white hover:text-yellow-400 transition-all duration-300">
                Exercises
              </Link>
            </li>
            <li>
              <Link to="/feedback" className="text-white hover:text-yellow-400 transition-all duration-300">
                Feedback
              </Link>
            </li>
            {auth?.user?.role === 1 && (
              <li>
                <Link to="/dashboard/admin" className="text-white hover:text-yellow-400 transition-all duration-300">
                  Admin Panel
                </Link>
              </li>
            )}
          </ul>

          {auth?.user ? (
            <>
              {/* Notification Bell for Admin */}
              {auth.user.role === 1 && (
                <div className="relative" ref={notifRef}>
                  <button onClick={() => setShowNotif(!showNotif)} className="relative text-white hover:text-yellow-400 transition-all">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                    </svg>
                    {notifications.length > 0 && (
                      <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs w-5 h-5 rounded-full flex items-center justify-center font-bold">
                        {notifications.length > 9 ? '9+' : notifications.length}
                      </span>
                    )}
                  </button>
                  {showNotif && (
                    <div className="absolute right-0 mt-2 w-80 bg-gray-800 rounded-lg shadow-2xl border border-gray-700 z-50 max-h-96 overflow-y-auto">
                      <div className="p-3 border-b border-gray-700 flex justify-between items-center">
                        <h4 className="text-white font-bold text-sm">Payment Reminders</h4>
                        <span className="text-xs text-gray-400">{notifications.length} alert(s)</span>
                      </div>
                      {notifications.length === 0 ? (
                        <div className="p-4 text-center text-gray-400 text-sm">No pending reminders</div>
                      ) : (
                        notifications.map((n, i) => (
                          <Link key={i} to={`/dashboard/admin/member/${n._id}`}
                            onClick={() => setShowNotif(false)}
                            className={`block px-4 py-3 border-b border-gray-700/50 hover:bg-gray-700/50 transition-all ${
                              n.type === 'overdue' ? 'border-l-4 border-l-red-500' : 'border-l-4 border-l-yellow-500'
                            }`}>
                            <p className="text-white text-sm">{n.message}</p>
                            <p className="text-gray-500 text-xs mt-1">
                              Due: {new Date(n.feeDueDate).toLocaleDateString()} | {n.contact}
                            </p>
                          </Link>
                        ))
                      )}
                      <Link to="/dashboard/admin/overdue-members" onClick={() => setShowNotif(false)}
                        className="block p-3 text-center text-blue-400 text-sm hover:bg-gray-700/50 font-medium">
                        View All Overdue →
                      </Link>
                    </div>
                  )}
                </div>
              )}
              <Link to={auth.user.role === 1 ? "/dashboard/admin" : "/dashboard/user"} className="text-white font-semibold hover:text-yellow-400 transition-all duration-300 capitalize">
                {auth.user.name}
              </Link>
              <button onClick={handleLogout} className="text-white hover:text-yellow-400 transition-all duration-300">
                Logout
              </button>
            </>
          ) : (
            <>
              <Link to="/register" className="text-white hover:text-yellow-400 transition-all duration-300">
                Register
              </Link>
              <Link to="/login" className="text-white hover:text-yellow-400 transition-all duration-300">
                Login
              </Link>
            </>
          )}
        </nav>
      </div>

      {/* Mobile Menu */}
      {isMobileMenuOpen && (
        <div className="lg:hidden bg-blue-600 py-4">
          <ul className="flex flex-col space-y-4 items-center text-lg">
            <li>
              <Link to="/" className="text-white hover:text-yellow-400 transition-all duration-300" onClick={() => setMobileMenuOpen(false)}>
                Home
              </Link>
            </li>
            <li>
              <Link to="/exercise" className="text-white hover:text-yellow-400 transition-all duration-300" onClick={() => setMobileMenuOpen(false)}>
                Exercises
              </Link>
            </li>
            <li>
              <Link to="/feedback" className="text-white hover:text-yellow-400 transition-all duration-300" onClick={() => setMobileMenuOpen(false)}>
                Feedback
              </Link>
            </li>
            {auth?.user?.role === 1 && (
              <>
                <li>
                  <Link to="/dashboard/admin" className="text-white hover:text-yellow-400 transition-all duration-300" onClick={() => setMobileMenuOpen(false)}>
                    Admin Panel
                  </Link>
                </li>
                <li>
                  <Link to="/dashboard/admin/overdue-members" className="text-white hover:text-yellow-400 transition-all duration-300 flex items-center gap-2" onClick={() => setMobileMenuOpen(false)}>
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                    </svg>
                    Reminders {notifications.length > 0 && <span className="bg-red-500 text-white text-xs w-5 h-5 rounded-full flex items-center justify-center font-bold">{notifications.length > 9 ? '9+' : notifications.length}</span>}
                  </Link>
                </li>
              </>
            )}
            {auth?.user ? (
              <>
                <Link to={auth.user.role === 1 ? "/dashboard/admin" : "/dashboard/user"} className="text-white font-semibold hover:text-yellow-400 transition-all duration-300 capitalize" onClick={() => setMobileMenuOpen(false)}>
                  {auth.user.name}
                </Link>
                <button onClick={() => { handleLogout(); setMobileMenuOpen(false); }} className="text-white hover:text-yellow-400 transition-all duration-300">
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link to="/register" className="text-white hover:text-yellow-400 transition-all duration-300" onClick={() => setMobileMenuOpen(false)}>
                  Register
                </Link>
                <Link to="/login" className="text-white hover:text-yellow-400 transition-all duration-300" onClick={() => setMobileMenuOpen(false)}>
                  Login
                </Link>
              </>
            )}
          </ul>
        </div>
      )}
    </header>
  );
};

export default Header;



