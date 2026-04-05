import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import { Heading, Loader } from '../../components';
import { toast } from 'react-hot-toast';
import { BASE_URL } from '../../utils/fetchData';
import { userImg } from '../../images';

const MemberProfile = () => {
  const { id } = useParams();
  const [member, setMember] = useState(null);
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, [id]);

  const fetchData = async () => {
    try {
      const [memberRes, paymentsRes] = await Promise.all([
        axios.get(`${BASE_URL}/api/v1/member/get-member/${id}`),
        axios.get(`${BASE_URL}/api/v1/fee/get-payments/${id}`),
      ]);
      if (memberRes.data?.success) setMember(memberRes.data.member);
      if (paymentsRes.data?.success) setPayments(paymentsRes.data.payments);
    } catch (err) {
      console.log(err);
      toast.error("Error loading member data");
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (d) => {
    if (!d) return 'N/A';
    return new Date(d).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'inactive': return 'bg-yellow-500';
      case 'expired': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  if (loading) return <Loader />;
  if (!member) return <div className="text-white text-center py-20">Member not found</div>;

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Member Profile" />
      <div className="container mx-auto px-4 sm:px-6 py-6 sm:py-10 max-w-4xl">
        {/* Profile Header */}
        <div className="bg-gray-800 rounded-lg p-4 sm:p-6 flex flex-col sm:flex-row items-center gap-4 sm:gap-6 mb-6 sm:mb-8">
          <img
            src={member.profilePic ? `${BASE_URL}${member.profilePic}` : userImg}
            alt={member.name}
            className="w-24 h-24 sm:w-32 sm:h-32 rounded-full object-cover border-4 border-blue-500"
          />
          <div className="text-center sm:text-left flex-1">
            <h2 className="text-white text-2xl sm:text-3xl font-bold">{member.name}</h2>
            <p className="text-gray-400 text-sm sm:text-base">{member.email}</p>
            <p className="text-gray-400 text-sm sm:text-base">{member.contact}</p>
            <div className="mt-2 flex gap-2 justify-center sm:justify-start flex-wrap">
              <span className={`px-3 py-1 rounded-full text-white text-sm ${getStatusColor(member.status)}`}>
                {member.status}
              </span>
              {member.gender && <span className="px-3 py-1 rounded-full bg-gray-600 text-white text-sm capitalize">{member.gender}</span>}
            </div>
          </div>
          <div className="flex gap-2">
            <Link to={`/dashboard/admin/edit-member/${member._id}`} className="px-3 sm:px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 text-sm">
              Edit
            </Link>
            <Link to={`/dashboard/admin/record-payment/${member._id}`} className="px-3 sm:px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm">
              Record Payment
            </Link>
          </div>
        </div>

        {/* Details Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6 mb-6 sm:mb-8">
          <div className="bg-gray-800 rounded-lg p-4 sm:p-6">
            <h3 className="text-white text-lg sm:text-xl font-bold mb-3 sm:mb-4">Personal Details</h3>
            <div className="space-y-3">
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">Age:</span><span className="text-white text-sm sm:text-base">{member.age || 'N/A'}</span></div>
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">City:</span><span className="text-white text-sm sm:text-base">{member.city || 'N/A'}</span></div>
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">Address:</span><span className="text-white text-sm sm:text-base text-right max-w-[60%]">{member.address || 'N/A'}</span></div>
            </div>
          </div>
          <div className="bg-gray-800 rounded-lg p-4 sm:p-6">
            <h3 className="text-white text-lg sm:text-xl font-bold mb-3 sm:mb-4">Membership & Fee</h3>
            <div className="space-y-3">
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">Monthly Fee:</span><span className="text-white text-sm sm:text-base">₹{member.feeAmount || 0}</span></div>
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">Fee Due Date:</span><span className={`font-semibold text-sm sm:text-base ${member.feeDueDate && new Date(member.feeDueDate) < new Date() ? 'text-red-400' : 'text-green-400'}`}>{formatDate(member.feeDueDate)}</span></div>
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">Membership Start:</span><span className="text-white text-sm sm:text-base">{formatDate(member.membershipStart)}</span></div>
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">Membership End:</span><span className="text-white text-sm sm:text-base">{formatDate(member.membershipEnd)}</span></div>
              <div className="flex justify-between"><span className="text-gray-400 text-sm sm:text-base">Joined:</span><span className="text-white text-sm sm:text-base">{formatDate(member.createdAt)}</span></div>
            </div>
          </div>
        </div>

        {/* Payment History */}
        <div className="bg-gray-800 rounded-lg p-4 sm:p-6">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 mb-4">
            <h3 className="text-white text-lg sm:text-xl font-bold">Payment History</h3>
            <Link to={`/dashboard/admin/record-payment/${member._id}`} className="px-3 sm:px-4 py-2 bg-green-600 text-white rounded-lg text-sm hover:bg-green-700">
              + Record Payment
            </Link>
          </div>
          {payments.length === 0 ? (
            <p className="text-gray-400 text-center py-8">No payment records yet</p>
          ) : (
            <>
              {/* Desktop Table */}
              <div className="hidden lg:block overflow-x-auto">
                <table className="w-full text-left">
                  <thead>
                    <tr className="border-b border-gray-700">
                      <th className="text-gray-400 py-2 px-3">#</th>
                      <th className="text-gray-400 py-2 px-3">Period Covered</th>
                      <th className="text-gray-400 py-2 px-3">Months</th>
                      <th className="text-gray-400 py-2 px-3">Amount</th>
                      <th className="text-gray-400 py-2 px-3">Due Date</th>
                      <th className="text-gray-400 py-2 px-3">Paid On</th>
                      <th className="text-gray-400 py-2 px-3">Timing</th>
                      <th className="text-gray-400 py-2 px-3">Status</th>
                      <th className="text-gray-400 py-2 px-3">Method</th>
                      <th className="text-gray-400 py-2 px-3">Remarks</th>
                    </tr>
                  </thead>
                  <tbody>
                    {payments.map((p, idx) => {
                      let timingBadge = null;
                      if (p.isPaid && p.paymentDate && p.dueDate) {
                        const paidDate = new Date(p.paymentDate);
                        const dueDate = new Date(p.dueDate);
                        const diffDays = Math.round((paidDate - dueDate) / (1000 * 60 * 60 * 24));
                        if (diffDays < 0) {
                          timingBadge = <span className="px-2 py-0.5 rounded text-xs font-bold bg-blue-600 text-white">{Math.abs(diffDays)}d Early</span>;
                        } else if (diffDays === 0) {
                          timingBadge = <span className="px-2 py-0.5 rounded text-xs font-bold bg-green-600 text-white">On Time</span>;
                        } else {
                          timingBadge = <span className="px-2 py-0.5 rounded text-xs font-bold bg-red-600 text-white">{diffDays}d Late</span>;
                        }
                      }
                      const coverPeriod = p.coverFrom && p.coverTo
                        ? `${formatDate(p.coverFrom)} — ${formatDate(p.coverTo)}`
                        : p.month || '-';
                      return (
                        <tr key={p._id} className="border-b border-gray-700/50 hover:bg-gray-700/30">
                          <td className="text-gray-400 py-3 px-3">{idx + 1}</td>
                          <td className="text-white py-3 px-3 font-medium">{coverPeriod}</td>
                          <td className="text-white py-3 px-3 text-center">
                            <span className="bg-purple-600/30 text-purple-300 px-2 py-0.5 rounded text-sm">{p.months || 1}</span>
                          </td>
                          <td className="text-white py-3 px-3 font-medium">₹{p.amount}</td>
                          <td className="text-gray-300 py-3 px-3">{formatDate(p.dueDate)}</td>
                          <td className="text-gray-300 py-3 px-3">{p.isPaid ? formatDate(p.paymentDate) : '-'}</td>
                          <td className="py-3 px-3">{timingBadge || <span className="text-gray-500 text-xs">-</span>}</td>
                          <td className="py-3 px-3">
                            <span className={`px-2 py-1 rounded text-sm font-bold ${p.isPaid ? 'bg-green-600 text-white' : 'bg-red-600 text-white'}`}>
                              {p.isPaid ? 'Paid' : 'Unpaid'}
                            </span>
                          </td>
                          <td className="text-gray-300 py-3 px-3 capitalize">{p.paymentMethod || '-'}</td>
                          <td className="text-gray-400 py-3 px-3 text-sm">{p.remarks || '-'}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              {/* Mobile Card Layout */}
              <div className="lg:hidden space-y-3">
                {payments.map((p, idx) => {
                  let timingBadge = null;
                  if (p.isPaid && p.paymentDate && p.dueDate) {
                    const paidDate = new Date(p.paymentDate);
                    const dueDate = new Date(p.dueDate);
                    const diffDays = Math.round((paidDate - dueDate) / (1000 * 60 * 60 * 24));
                    if (diffDays < 0) {
                      timingBadge = <span className="px-2 py-0.5 rounded text-xs font-bold bg-blue-600 text-white">{Math.abs(diffDays)}d Early</span>;
                    } else if (diffDays === 0) {
                      timingBadge = <span className="px-2 py-0.5 rounded text-xs font-bold bg-green-600 text-white">On Time</span>;
                    } else {
                      timingBadge = <span className="px-2 py-0.5 rounded text-xs font-bold bg-red-600 text-white">{diffDays}d Late</span>;
                    }
                  }
                  const coverPeriod = p.coverFrom && p.coverTo
                    ? `${formatDate(p.coverFrom)} — ${formatDate(p.coverTo)}`
                    : p.month || '-';

                  return (
                    <div key={p._id} className="bg-gray-700/30 rounded-lg p-3 border border-gray-700/50">
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <p className="text-purple-300 text-sm font-medium">{coverPeriod}</p>
                          <p className="text-white font-bold text-lg">₹{p.amount}</p>
                        </div>
                        <div className="flex gap-1 items-center">
                          <span className="bg-purple-600/30 text-purple-300 px-2 py-0.5 rounded text-xs">{p.months || 1} mo</span>
                          <span className={`px-2 py-0.5 rounded text-xs font-bold ${p.isPaid ? 'bg-green-600 text-white' : 'bg-red-600 text-white'}`}>
                            {p.isPaid ? 'Paid' : 'Unpaid'}
                          </span>
                        </div>
                      </div>
                      <div className="grid grid-cols-2 gap-1 text-xs">
                        <div><span className="text-gray-500">Due: </span><span className="text-gray-300">{formatDate(p.dueDate)}</span></div>
                        <div><span className="text-gray-500">Paid: </span><span className="text-gray-300">{p.isPaid ? formatDate(p.paymentDate) : '-'}</span></div>
                        <div><span className="text-gray-500">Method: </span><span className="text-gray-300 capitalize">{p.paymentMethod || '-'}</span></div>
                        <div>{timingBadge || <span className="text-gray-500">-</span>}</div>
                      </div>
                      {p.remarks && <p className="text-gray-500 text-xs mt-1">{p.remarks}</p>}
                    </div>
                  );
                })}
              </div>

              {/* Summary */}
              <div className="mt-4 pt-4 border-t border-gray-700 flex flex-wrap gap-4 sm:gap-6">
                <div>
                  <span className="text-gray-400 text-xs sm:text-sm">Total Paid: </span>
                  <span className="text-green-400 font-bold text-sm sm:text-base">₹{payments.filter(p => p.isPaid).reduce((s, p) => s + p.amount, 0)}</span>
                </div>
                <div>
                  <span className="text-gray-400 text-xs sm:text-sm">Total Unpaid: </span>
                  <span className="text-red-400 font-bold text-sm sm:text-base">₹{payments.filter(p => !p.isPaid).reduce((s, p) => s + p.amount, 0)}</span>
                </div>
                <div>
                  <span className="text-gray-400 text-xs sm:text-sm">Payments: </span>
                  <span className="text-white font-bold text-sm sm:text-base">{payments.length}</span>
                </div>
              </div>
            </>
          )}
        </div>

        {/* Back Button */}
        <div className="mt-6">
          <Link to="/dashboard/admin/member-list" className="text-blue-400 hover:text-blue-300 text-sm sm:text-base">
            ← Back to Members
          </Link>
        </div>
      </div>
    </section>
  );
};

export default MemberProfile;
