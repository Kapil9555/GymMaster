import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { Heading, Loader } from '../../components';
import { toast } from 'react-hot-toast';
import { BASE_URL } from '../../utils/fetchData';
import { userImg } from '../../images';

const FeeManagement = () => {
  const [payments, setPayments] = useState([]);
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [paymentsRes, summaryRes] = await Promise.all([
        axios.get(`${BASE_URL}/api/v1/fee/get-all-payments`),
        axios.get(`${BASE_URL}/api/v1/fee/fee-summary`),
      ]);
      if (paymentsRes.data?.success) setPayments(paymentsRes.data.payments);
      if (summaryRes.data?.success) setSummary(summaryRes.data.summary);
    } catch (err) {
      console.log(err);
      toast.error("Error loading fee data");
    } finally {
      setLoading(false);
    }
  };

  const handleMarkPaid = async (paymentId) => {
    try {
      const res = await axios.put(`${BASE_URL}/api/v1/fee/mark-paid/${paymentId}`, {
        paymentMethod: 'cash',
      });
      if (res.data?.success) {
        toast.success("Marked as paid");
        fetchData();
      }
    } catch (err) {
      console.log(err);
      toast.error("Error updating payment");
    }
  };

  const handleMarkUnpaid = async (paymentId) => {
    try {
      const res = await axios.put(`${BASE_URL}/api/v1/fee/mark-unpaid/${paymentId}`);
      if (res.data?.success) {
        toast.success("Marked as unpaid");
        fetchData();
      }
    } catch (err) {
      console.log(err);
      toast.error("Error updating payment");
    }
  };

  const formatDate = (d) => {
    if (!d) return 'N/A';
    return new Date(d).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
  };

  if (loading) return <Loader />;

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Fee Management" />
      <div className="container mx-auto px-4 sm:px-6 py-6 sm:py-10">
        {/* Summary Cards */}
        {summary && (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 mb-6 sm:mb-10">
            <div className="bg-blue-700 p-3 sm:p-4 rounded-lg text-center">
              <p className="text-blue-200 text-xs sm:text-sm">Total Members</p>
              <p className="text-white text-2xl sm:text-3xl font-bold">{summary.totalMembers}</p>
            </div>
            <div className="bg-green-700 p-3 sm:p-4 rounded-lg text-center">
              <p className="text-green-200 text-xs sm:text-sm">Paid ({summary.currentMonth})</p>
              <p className="text-white text-2xl sm:text-3xl font-bold">{summary.paidCount}</p>
              <p className="text-green-300 text-xs sm:text-sm">₹{summary.totalCollected}</p>
            </div>
            <div className="bg-red-700 p-3 sm:p-4 rounded-lg text-center">
              <p className="text-red-200 text-xs sm:text-sm">Unpaid ({summary.currentMonth})</p>
              <p className="text-white text-2xl sm:text-3xl font-bold">{summary.unpaidCount}</p>
              <p className="text-red-300 text-xs sm:text-sm">₹{summary.totalPending}</p>
            </div>
            <div className="bg-yellow-700 p-3 sm:p-4 rounded-lg text-center">
              <p className="text-yellow-200 text-xs sm:text-sm">Overdue</p>
              <p className="text-white text-2xl sm:text-3xl font-bold">{summary.overdueCount}</p>
            </div>
          </div>
        )}

        {/* Payment Records */}
        <div className="flex justify-between items-center mb-4 sm:mb-6">
          <h3 className="text-white text-lg sm:text-xl font-bold">All Payment Records</h3>
        </div>

        {payments.length === 0 ? (
          <div className="text-center py-20">
            <p className="text-gray-400 text-lg sm:text-xl">No payment records found</p>
            <p className="text-gray-500 mt-2 text-sm sm:text-base">Add members and record their payments from the member profile page</p>
          </div>
        ) : (
          <>
            {/* Desktop Table */}
            <div className="hidden lg:block overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-gray-700">
                    <th className="text-gray-400 py-3 px-3">Member</th>
                    <th className="text-gray-400 py-3 px-3">Month</th>
                    <th className="text-gray-400 py-3 px-3">Amount</th>
                    <th className="text-gray-400 py-3 px-3">Due Date</th>
                    <th className="text-gray-400 py-3 px-3">Paid On</th>
                    <th className="text-gray-400 py-3 px-3">Status</th>
                    <th className="text-gray-400 py-3 px-3">Method</th>
                    <th className="text-gray-400 py-3 px-3">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {payments.map((p) => (
                    <tr key={p._id} className="border-b border-gray-800 hover:bg-gray-800">
                      <td className="py-3 px-3">
                        <div className="flex items-center gap-2">
                          <img src={p.user?.profilePic ? `${BASE_URL}${p.user.profilePic}` : userImg} alt="" className="w-8 h-8 rounded-full object-cover" />
                          <Link to={`/dashboard/admin/member/${p.user?._id}`} className="text-blue-400 hover:text-blue-300">
                            {p.user?.name || 'Unknown'}
                          </Link>
                        </div>
                      </td>
                      <td className="text-white py-3 px-3">{p.month}</td>
                      <td className="text-white py-3 px-3">₹{p.amount}</td>
                      <td className="text-gray-300 py-3 px-3">{formatDate(p.dueDate)}</td>
                      <td className="text-gray-300 py-3 px-3">{formatDate(p.paymentDate)}</td>
                      <td className="py-3 px-3">
                        <span className={`px-2 py-1 rounded text-sm ${p.isPaid ? 'bg-green-600 text-white' : 'bg-red-600 text-white'}`}>
                          {p.isPaid ? 'Paid' : 'Unpaid'}
                        </span>
                      </td>
                      <td className="text-gray-300 py-3 px-3 capitalize">{p.paymentMethod || '-'}</td>
                      <td className="py-3 px-3">
                        {p.isPaid ? (
                          <button onClick={() => handleMarkUnpaid(p._id)} className="px-3 py-1 bg-red-600 text-white rounded text-sm hover:bg-red-700">
                            Mark Unpaid
                          </button>
                        ) : (
                          <button onClick={() => handleMarkPaid(p._id)} className="px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700">
                            Mark Paid
                          </button>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Mobile Card Layout */}
            <div className="lg:hidden space-y-3">
              {payments.map((p) => (
                <div key={p._id} className="bg-gray-800 rounded-lg p-4">
                  <div className="flex items-center gap-2 mb-2">
                    <img src={p.user?.profilePic ? `${BASE_URL}${p.user.profilePic}` : userImg} alt="" className="w-8 h-8 rounded-full object-cover" />
                    <Link to={`/dashboard/admin/member/${p.user?._id}`} className="text-blue-400 hover:text-blue-300 font-medium text-sm">
                      {p.user?.name || 'Unknown'}
                    </Link>
                    <span className={`ml-auto px-2 py-0.5 rounded text-xs font-bold ${p.isPaid ? 'bg-green-600 text-white' : 'bg-red-600 text-white'}`}>
                      {p.isPaid ? 'Paid' : 'Unpaid'}
                    </span>
                  </div>
                  <div className="flex justify-between items-center mb-2">
                    <p className="text-purple-300 text-sm">{p.month}</p>
                    <p className="text-white font-bold">₹{p.amount}</p>
                  </div>
                  <div className="grid grid-cols-2 gap-1 text-xs mb-3">
                    <div><span className="text-gray-500">Due: </span><span className="text-gray-300">{formatDate(p.dueDate)}</span></div>
                    <div><span className="text-gray-500">Paid: </span><span className="text-gray-300">{formatDate(p.paymentDate)}</span></div>
                    <div><span className="text-gray-500">Method: </span><span className="text-gray-300 capitalize">{p.paymentMethod || '-'}</span></div>
                  </div>
                  {p.isPaid ? (
                    <button onClick={() => handleMarkUnpaid(p._id)} className="w-full py-2 bg-red-600 text-white rounded text-sm hover:bg-red-700 font-medium">
                      Mark Unpaid
                    </button>
                  ) : (
                    <button onClick={() => handleMarkPaid(p._id)} className="w-full py-2 bg-green-600 text-white rounded text-sm hover:bg-green-700 font-medium">
                      Mark Paid
                    </button>
                  )}
                </div>
              ))}
            </div>
          </>
        )}
      </div>
    </section>
  );
};

export default FeeManagement;
