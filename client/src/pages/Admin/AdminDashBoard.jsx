import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import axios from "axios";
import { Heading, Loader } from '../../components';
import { toast } from "react-hot-toast";
import { BASE_URL } from "../../utils/fetchData";
import AOS from 'aos';
import 'aos/dist/aos.css';

const AdminDashBoard = () => {
  const [memberCount, setMemberCount] = useState(null);
  const [planCount, setPlanCount] = useState(null);
  const [subscriberCount, setSubscriberCount] = useState(null);
  const [contactCount, setContactCount] = useState(null);
  const [feedbackCount, setFeedbackCount] = useState(null);
  const [feeSummary, setFeeSummary] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    AOS.init({ duration: 1000, easing: 'ease-in-out', once: true });
    fetchAllCounts();
  }, []);

  const fetchAllCounts = async () => {
    try {
      const [plansRes, subsRes, contactsRes, feedbacksRes, membersRes, feeRes] = await Promise.all([
        axios.get(`${BASE_URL}/api/v1/plan/total-plan`).catch(() => ({ data: { total: 0 } })),
        axios.get(`${BASE_URL}/api/v1/subscription/total-subscription`).catch(() => ({ data: { total: 0 } })),
        axios.get(`${BASE_URL}/api/v1/contact/total-contact`).catch(() => ({ data: { total: 0 } })),
        axios.get(`${BASE_URL}/api/v1/feedback/total-feedback`).catch(() => ({ data: { total: 0 } })),
        axios.get(`${BASE_URL}/api/v1/member/total-members`).catch(() => ({ data: { total: 0 } })),
        axios.get(`${BASE_URL}/api/v1/fee/fee-summary`).catch(() => ({ data: { summary: null } })),
      ]);

      setPlanCount(plansRes.data?.total ?? 0);
      setSubscriberCount(subsRes.data?.total ?? 0);
      setContactCount(contactsRes.data?.total ?? 0);
      setFeedbackCount(feedbacksRes.data?.total ?? 0);
      setMemberCount(membersRes.data?.total ?? 0);
      setFeeSummary(feeRes.data?.summary ?? null);
    } catch (err) {
      console.log(err);
      toast.error("Error loading dashboard data");
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <Loader />;

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Admin Dashboard" />
      <div className="container mx-auto px-4 sm:px-6 py-6 sm:py-10">
        {/* Main Stats */}
        <h3 className="text-white text-2xl font-bold mb-6">Overview</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 mb-10">
          <Link className='p-6 bg-gradient-to-r from-blue-600 to-blue-800 rounded-lg hover:scale-105 transition-all shadow-lg' to="/dashboard/admin/member-list" data-aos="fade-up">
            <h2 className='text-white font-bold text-2xl'>Members</h2>
            <p className='text-blue-200 text-4xl font-extrabold mt-2'>{memberCount ?? 0}</p>
          </Link>
          <Link className='p-6 bg-gradient-to-r from-green-600 to-green-800 rounded-lg hover:scale-105 transition-all shadow-lg' to="/dashboard/admin/fee-management" data-aos="fade-up" data-aos-delay="100">
            <h2 className='text-white font-bold text-2xl'>Fee Collected</h2>
            <p className='text-green-200 text-4xl font-extrabold mt-2'>₹{feeSummary?.totalCollected ?? 0}</p>
            <p className='text-green-300 text-sm mt-1'>{feeSummary?.currentMonth ?? ""}</p>
          </Link>
          <Link className='p-6 bg-gradient-to-r from-red-600 to-red-800 rounded-lg hover:scale-105 transition-all shadow-lg' to="/dashboard/admin/overdue-members" data-aos="fade-up" data-aos-delay="200">
            <h2 className='text-white font-bold text-2xl'>Overdue</h2>
            <p className='text-red-200 text-4xl font-extrabold mt-2'>{feeSummary?.overdueCount ?? 0}</p>
            <p className='text-red-300 text-sm mt-1'>Members with pending fees</p>
          </Link>
        </div>

        {/* Manage Section */}
        <h3 className="text-white text-2xl font-bold mb-6">Manage</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-10">
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/member-list" data-aos="fade-up">
            <h2 className='text-white font-bold text-xl'>All Members</h2>
            <p className='text-gray-400 mt-1'>View & manage gym members</p>
          </Link>
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/add-member" data-aos="fade-up" data-aos-delay="100">
            <h2 className='text-white font-bold text-xl'>Add Member</h2>
            <p className='text-gray-400 mt-1'>Register new member</p>
          </Link>
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/fee-management" data-aos="fade-up" data-aos-delay="200">
            <h2 className='text-white font-bold text-xl'>Fee Management</h2>
            <p className='text-gray-400 mt-1'>Track & record payments</p>
          </Link>
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/overdue-members" data-aos="fade-up" data-aos-delay="300">
            <h2 className='text-white font-bold text-xl'>Overdue Fees</h2>
            <p className='text-gray-400 mt-1'>Members with pending dues</p>
          </Link>
        </div>

        {/* Other */}
        <h3 className="text-white text-2xl font-bold mb-6">Other</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/plans" data-aos="fade-up">
            <h2 className='text-white font-bold text-xl'>Plans: {planCount ?? 0}</h2>
          </Link>
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/subscriber-list" data-aos="fade-up" data-aos-delay="100">
            <h2 className='text-white font-bold text-xl'>Subscribers: {subscriberCount ?? 0}</h2>
          </Link>
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/contact-us" data-aos="fade-up" data-aos-delay="200">
            <h2 className='text-white font-bold text-xl'>Queries: {contactCount ?? 0}</h2>
          </Link>
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/feedbacks" data-aos="fade-up" data-aos-delay="300">
            <h2 className='text-white font-bold text-xl'>Feedbacks: {feedbackCount ?? 0}</h2>
          </Link>
          <Link className='p-5 bg-gray-800 border border-gray-700 rounded-lg hover:bg-blue-600 transition-all' to="/dashboard/admin/create-plane" data-aos="fade-up" data-aos-delay="400">
            <h2 className='text-white font-bold text-xl'>Create Plan</h2>
          </Link>
        </div>
      </div>
    </section>
  );
}

export default AdminDashBoard;
