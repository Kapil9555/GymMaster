import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { Heading, Loader } from '../../components';
import { toast } from 'react-hot-toast';
import { BASE_URL } from '../../utils/fetchData';

const OverdueMembers = () => {
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchOverdue();
  }, []);

  const fetchOverdue = async () => {
    try {
      const res = await axios.get(`${BASE_URL}/api/v1/fee/overdue-members`);
      if (res.data?.success) {
        setMembers(res.data.overdueMembers || []);
      }
    } catch (err) {
      console.log(err);
      toast.error("Error fetching overdue members");
    } finally {
      setLoading(false);
    }
  };

  const getDaysOverdue = (dueDate) => {
    const diff = Math.floor((new Date() - new Date(dueDate)) / (1000 * 60 * 60 * 24));
    return diff;
  };

  if (loading) return <Loader />;

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Overdue Members" />
      <div className="container mx-auto px-4 sm:px-6 py-6 sm:py-10">
        <div className="bg-yellow-900/30 border border-yellow-600 p-3 sm:p-4 rounded-lg mb-4 sm:mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
          <div>
            <h3 className="text-yellow-400 font-bold text-base sm:text-lg">Total Overdue: {members.length}</h3>
            <p className="text-yellow-300 text-xs sm:text-sm">Members whose fee due date has passed</p>
          </div>
          <Link to="/dashboard/admin/fee-management" className="bg-yellow-600 px-3 sm:px-4 py-2 rounded text-white hover:bg-yellow-700 font-medium text-sm whitespace-nowrap">
            Fee Dashboard
          </Link>
        </div>

        {members.length === 0 ? (
          <div className="text-center py-20">
            <h3 className="text-xl sm:text-2xl text-green-400 font-bold">No overdue members!</h3>
            <p className="text-gray-400 mt-2 text-sm sm:text-base">All members have paid their fees on time.</p>
          </div>
        ) : (
          <>
            {/* Desktop Table */}
            <div className="hidden lg:block overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-gray-700">
                    <th className="py-3 px-4 text-gray-400">#</th>
                    <th className="py-3 px-4 text-gray-400">Name</th>
                    <th className="py-3 px-4 text-gray-400">Phone</th>
                    <th className="py-3 px-4 text-gray-400">Fee Amount</th>
                    <th className="py-3 px-4 text-gray-400">Due Date</th>
                    <th className="py-3 px-4 text-gray-400">Days Overdue</th>
                    <th className="py-3 px-4 text-gray-400">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {members.map((m, i) => {
                    const days = getDaysOverdue(m.feeDueDate);
                    return (
                      <tr key={m._id} className="border-b border-gray-800 hover:bg-gray-800/50">
                        <td className="py-3 px-4 text-gray-400">{i + 1}</td>
                        <td className="py-3 px-4">
                          <Link to={`/dashboard/admin/member/${m._id}`} className="text-white hover:text-blue-400 font-medium">
                            {m.name}
                          </Link>
                        </td>
                        <td className="py-3 px-4 text-gray-300">{m.contact || '-'}</td>
                        <td className="py-3 px-4 text-white font-medium">₹{m.feeAmount || 0}</td>
                        <td className="py-3 px-4 text-red-400">{new Date(m.feeDueDate).toLocaleDateString()}</td>
                        <td className="py-3 px-4">
                          <span className={`px-2 py-1 rounded text-sm font-bold ${
                            days > 30 ? 'bg-red-600 text-white' : days > 7 ? 'bg-orange-600 text-white' : 'bg-yellow-600 text-white'
                          }`}>{days} days</span>
                        </td>
                        <td className="py-3 px-4 flex gap-2">
                          <Link to={`/dashboard/admin/record-payment/${m._id}`}
                            className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700 font-medium">
                            Record Payment
                          </Link>
                          <a href={`tel:${m.contact}`}
                            className="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700 font-medium">
                            Call
                          </a>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            {/* Mobile Card Layout */}
            <div className="lg:hidden space-y-3">
              {members.map((m, i) => {
                const days = getDaysOverdue(m.feeDueDate);
                return (
                  <div key={m._id} className="bg-gray-800 rounded-lg p-4">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <Link to={`/dashboard/admin/member/${m._id}`} className="text-white hover:text-blue-400 font-medium">
                          {m.name}
                        </Link>
                        <p className="text-gray-400 text-sm">{m.contact || '-'}</p>
                      </div>
                      <span className={`px-2 py-1 rounded text-xs font-bold ${
                        days > 30 ? 'bg-red-600 text-white' : days > 7 ? 'bg-orange-600 text-white' : 'bg-yellow-600 text-white'
                      }`}>{days}d overdue</span>
                    </div>
                    <div className="flex justify-between items-center text-sm mb-3">
                      <span className="text-white font-medium">₹{m.feeAmount || 0}</span>
                      <span className="text-red-400 text-xs">Due: {new Date(m.feeDueDate).toLocaleDateString()}</span>
                    </div>
                    <div className="flex gap-2">
                      <Link to={`/dashboard/admin/record-payment/${m._id}`}
                        className="flex-1 bg-green-600 text-white px-3 py-2 rounded text-sm hover:bg-green-700 font-medium text-center">
                        Record Payment
                      </Link>
                      <a href={`tel:${m.contact}`}
                        className="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700 font-medium">
                        Call
                      </a>
                    </div>
                  </div>
                );
              })}
            </div>
          </>
        )}
      </div>
    </section>
  );
};

export default OverdueMembers;
