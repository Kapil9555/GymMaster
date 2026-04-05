import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Heading } from '../../components';
import { useAuth } from "../../context/auth";
import AOS from 'aos';
import 'aos/dist/aos.css';

const UserDashBoard = () => {
  const { auth } = useAuth();

  useEffect(() => {
    AOS.init({ duration: 1000 });
  }, []);

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="User Dashboard" />
      <div className="container mx-auto px-6 py-20">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5 items-stretch">
          <Link
            className='p-5 border border-white hover:bg-blue-600 transition-all rounded-lg'
            to="/dashboard/user/plan-detail"
            data-aos="fade-up"
          >
            <h2 className='text-white font-bold text-3xl'>Plan Detail</h2>
          </Link>

          <Link
            className='p-5 border border-white hover:bg-blue-600 transition-all rounded-lg'
            to="/dashboard/user/favourite-exercises"
            data-aos="fade-up"
          >
            <h2 className='text-white font-bold text-3xl'>Favourite Exercises</h2>
          </Link>

          <Link
            className='p-5 border border-white hover:bg-blue-600 transition-all rounded-lg'
            to="/dashboard/user/profile"
            data-aos="fade-up"
          >
            <h2 className='text-white font-bold text-3xl'>Profile</h2>
          </Link>

          <Link
            className='p-5 border border-white hover:bg-blue-600 transition-all rounded-lg'
            to="/dashboard/user/feedbacks"
            data-aos="fade-up"
          >
            <h2 className='text-white font-bold text-3xl'>Feedbacks</h2>
          </Link>
        </div>
      </div>
    </section>
  );
}

export default UserDashBoard;
