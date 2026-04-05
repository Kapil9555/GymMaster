import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { Heading, Loader } from '../../components';
import { toast } from 'react-hot-toast';
import { BASE_URL } from '../../utils/fetchData';
import { userImg } from '../../images';

const MemberList = () => {
  const [members, setMembers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterFee, setFilterFee] = useState('all');

  // Payment modal state
  const [paymentModal, setPaymentModal] = useState(false);
  const [paymentMember, setPaymentMember] = useState(null);
  const [paymentData, setPaymentData] = useState({
    months: 1,
    paymentMethod: 'cash',
    remarks: '',
  });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchMembers();
  }, []);

  const fetchMembers = async () => {
    try {
      const res = await axios.get(`${BASE_URL}/api/v1/member/get-all-members`);
      if (res.data?.success) {
        setMembers(res.data.members);
      }
    } catch (err) {
      console.log(err);
      toast.error("Error fetching members");
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async () => {
    if (!searchQuery.trim()) {
      fetchMembers();
      return;
    }
    try {
      setLoading(true);
      const res = await axios.get(`${BASE_URL}/api/v1/member/search-members?q=${encodeURIComponent(searchQuery)}`);
      if (res.data?.success) {
        setMembers(res.data.members);
      }
    } catch (err) {
      console.log(err);
      toast.error("Error searching members");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id, name) => {
    const confirm = window.confirm(`Are you sure you want to delete member "${name}"?`);
    if (!confirm) return;
    try {
      const res = await axios.delete(`${BASE_URL}/api/v1/member/delete-member/${id}`);
      if (res.data?.success) {
        toast.success("Member deleted");
        setMembers(members.filter(m => m._id !== id));
      }
    } catch (err) {
      console.log(err);
      toast.error("Error deleting member");
    }
  };

  const handleStatusChange = async (id, newStatus) => {
    try {
      const res = await axios.put(`${BASE_URL}/api/v1/member/update-status/${id}`, { status: newStatus });
      if (res.data?.success) {
        toast.success("Status updated");
        setMembers(members.map(m => m._id === id ? { ...m, status: newStatus } : m));
      }
    } catch (err) {
      console.log(err);
      toast.error("Error updating status");
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'inactive': return 'bg-yellow-500';
      case 'expired': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  const getFeeStatus = (member) => {
    if (!member.feeDueDate) return { text: 'Not Set', color: 'text-gray-400', key: 'notset' };
    const due = new Date(member.feeDueDate);
    const today = new Date();
    if (due < today) return { text: 'Overdue', color: 'text-red-400', key: 'overdue' };
    const daysLeft = Math.ceil((due - today) / (1000 * 60 * 60 * 24));
    if (daysLeft <= 5) return { text: `Due in ${daysLeft}d`, color: 'text-yellow-400', key: 'upcoming' };
    return { text: 'Paid', color: 'text-green-400', key: 'paid' };
  };

  const formatMonth = (d) => d.toLocaleString('en-IN', { month: 'short', year: 'numeric' });

  // Compute cover period for payment modal preview
  const getCoverPeriod = () => {
    if (!paymentMember) return '';
    const base = paymentMember.feeDueDate ? new Date(paymentMember.feeDueDate) : new Date();
    const from = new Date(base);
    const to = new Date(base);
    to.setMonth(to.getMonth() + paymentData.months);
    return paymentData.months === 1 ? formatMonth(from) : `${formatMonth(from)} → ${formatMonth(to)}`;
  };

  // Open payment modal
  const openPaymentModal = (member) => {
    setPaymentMember(member);
    setPaymentData({ months: 1, paymentMethod: 'cash', remarks: '' });
    setPaymentModal(true);
  };

  // Submit payment
  const handlePaymentSubmit = async () => {
    if (!paymentMember) return;
    setSubmitting(true);
    try {
      const totalAmount = (paymentMember.feeAmount || 0) * paymentData.months;
      const res = await axios.post(`${BASE_URL}/api/v1/fee/create-payment`, {
        userId: paymentMember._id,
        amount: totalAmount,
        months: paymentData.months,
        isPaid: true,
        paymentMethod: paymentData.paymentMethod,
        remarks: paymentData.remarks,
      });
      if (res.data?.success) {
        toast.success(`Payment of ₹${totalAmount} recorded for ${paymentData.months} month(s)!`);
        setPaymentModal(false);
        fetchMembers();
      } else {
        toast.error(res.data?.message || "Error recording payment");
      }
    } catch (err) {
      console.log(err);
      toast.error("Error recording payment");
    } finally {
      setSubmitting(false);
    }
  };

  // Filter members
  const filteredMembers = members.filter(m => {
    if (filterStatus !== 'all' && m.status !== filterStatus) return false;
    if (filterFee !== 'all') {
      const fs = getFeeStatus(m).key;
      if (filterFee === 'paid' && fs !== 'paid') return false;
      if (filterFee === 'overdue' && fs !== 'overdue') return false;
      if (filterFee === 'upcoming' && fs !== 'upcoming') return false;
      if (filterFee === 'notset' && fs !== 'notset') return false;
    }
    return true;
  });

  if (loading) return <Loader />;

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Gym Members" />
      <div className="container mx-auto px-4 sm:px-6 py-6 sm:py-10">
        {/* Search & Actions Bar */}
        <div className="flex flex-col gap-3 mb-6 sm:mb-8">
          <div className="flex gap-2 w-full">
            <input
              type="text"
              placeholder="Search by name, email, phone..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
              className="px-3 sm:px-4 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 focus:border-blue-500 outline-none flex-1 md:max-w-xs text-sm sm:text-base"
            />
            <button onClick={handleSearch} className="px-3 sm:px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm sm:text-base">
              Search
            </button>
          </div>
          <div className="flex gap-2 sm:gap-3 items-center flex-wrap">
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="px-2 sm:px-3 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 text-sm flex-1 min-w-0 sm:flex-none"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="expired">Expired</option>
            </select>
            <select
              value={filterFee}
              onChange={(e) => setFilterFee(e.target.value)}
              className="px-2 sm:px-3 py-2 rounded-lg bg-gray-800 text-white border border-gray-600 text-sm flex-1 min-w-0 sm:flex-none"
            >
              <option value="all">All Payments</option>
              <option value="paid">Paid</option>
              <option value="overdue">Overdue</option>
              <option value="upcoming">Due Soon</option>
              <option value="notset">Not Set</option>
            </select>
            <Link to="/dashboard/admin/add-member" className="px-3 sm:px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 whitespace-nowrap text-sm">
              + Add Member
            </Link>
          </div>
        </div>

        {/* Members Count */}
        <p className="text-gray-400 mb-4 text-sm sm:text-base">Showing {filteredMembers.length} member(s)</p>

        {/* Members */}
        {filteredMembers.length === 0 ? (
          <div className="text-center py-20">
            <p className="text-gray-400 text-xl">No members found</p>
          </div>
        ) : (
          <>
            {/* Desktop Table */}
            <div className="hidden lg:block overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-gray-700">
                    <th className="text-gray-400 py-3 px-4">#</th>
                    <th className="text-gray-400 py-3 px-4">Photo</th>
                    <th className="text-gray-400 py-3 px-4">Name</th>
                    <th className="text-gray-400 py-3 px-4">Phone</th>
                    <th className="text-gray-400 py-3 px-4">Fee (₹)</th>
                    <th className="text-gray-400 py-3 px-4">Fee Status</th>
                    <th className="text-gray-400 py-3 px-4">Next Due</th>
                    <th className="text-gray-400 py-3 px-4">Status</th>
                    <th className="text-gray-400 py-3 px-4">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredMembers.map((member, i) => {
                    const feeStatus = getFeeStatus(member);
                    return (
                      <tr key={member._id} className="border-b border-gray-800 hover:bg-gray-800 transition-all">
                        <td className="text-gray-300 py-3 px-4">{i + 1}</td>
                        <td className="py-3 px-4">
                          <img
                            src={member.profilePic ? `${BASE_URL}${member.profilePic}` : userImg}
                            alt={member.name}
                            className="w-10 h-10 rounded-full object-cover border-2 border-gray-600"
                          />
                        </td>
                        <td className="text-white py-3 px-4 font-medium">{member.name}</td>
                        <td className="text-gray-300 py-3 px-4">{member.contact}</td>
                        <td className="text-gray-300 py-3 px-4">₹{member.feeAmount || 0}</td>
                        <td className={`py-3 px-4 font-semibold ${feeStatus.color}`}>{feeStatus.text}</td>
                        <td className="text-gray-300 py-3 px-4 text-sm">
                          {member.feeDueDate ? new Date(member.feeDueDate).toLocaleDateString() : '-'}
                        </td>
                        <td className="py-3 px-4">
                          <select
                            value={member.status}
                            onChange={(e) => handleStatusChange(member._id, e.target.value)}
                            className={`px-2 py-1 rounded text-white text-sm ${getStatusColor(member.status)}`}
                          >
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                            <option value="expired">Expired</option>
                          </select>
                        </td>
                        <td className="py-3 px-4">
                          <div className="flex gap-2 flex-wrap">
                            <button onClick={() => openPaymentModal(member)} className="px-3 py-1 bg-purple-600 text-white rounded text-sm hover:bg-purple-700">
                              Pay
                            </button>
                            <Link to={`/dashboard/admin/member/${member._id}`} className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700">
                              View
                            </Link>
                            <Link to={`/dashboard/admin/edit-member/${member._id}`} className="px-3 py-1 bg-yellow-600 text-white rounded text-sm hover:bg-yellow-700">
                              Edit
                            </Link>
                            <button onClick={() => handleDelete(member._id, member.name)} className="px-3 py-1 bg-red-600 text-white rounded text-sm hover:bg-red-700">
                              Delete
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            {/* Mobile Card Layout */}
            <div className="lg:hidden space-y-3">
              {filteredMembers.map((member, i) => {
                const feeStatus = getFeeStatus(member);
                return (
                  <div key={member._id} className="bg-gray-800 rounded-lg p-4">
                    <div className="flex items-center gap-3 mb-3">
                      <img
                        src={member.profilePic ? `${BASE_URL}${member.profilePic}` : userImg}
                        alt={member.name}
                        className="w-12 h-12 rounded-full object-cover border-2 border-gray-600"
                      />
                      <div className="flex-1 min-w-0">
                        <h4 className="text-white font-medium truncate">{member.name}</h4>
                        <p className="text-gray-400 text-sm">{member.contact}</p>
                      </div>
                      <select
                        value={member.status}
                        onChange={(e) => handleStatusChange(member._id, e.target.value)}
                        className={`px-2 py-1 rounded text-white text-xs ${getStatusColor(member.status)}`}
                      >
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                        <option value="expired">Expired</option>
                      </select>
                    </div>
                    <div className="grid grid-cols-3 gap-2 text-sm mb-3">
                      <div>
                        <span className="text-gray-500 text-xs">Fee</span>
                        <p className="text-white font-medium">₹{member.feeAmount || 0}</p>
                      </div>
                      <div>
                        <span className="text-gray-500 text-xs">Status</span>
                        <p className={`font-semibold ${feeStatus.color}`}>{feeStatus.text}</p>
                      </div>
                      <div>
                        <span className="text-gray-500 text-xs">Next Due</span>
                        <p className="text-gray-300">{member.feeDueDate ? new Date(member.feeDueDate).toLocaleDateString() : '-'}</p>
                      </div>
                    </div>
                    <div className="flex gap-2 flex-wrap">
                      <button onClick={() => openPaymentModal(member)} className="px-3 py-1.5 bg-purple-600 text-white rounded text-xs hover:bg-purple-700 font-medium">
                        Pay
                      </button>
                      <Link to={`/dashboard/admin/member/${member._id}`} className="px-3 py-1.5 bg-blue-600 text-white rounded text-xs hover:bg-blue-700 font-medium">
                        View
                      </Link>
                      <Link to={`/dashboard/admin/edit-member/${member._id}`} className="px-3 py-1.5 bg-yellow-600 text-white rounded text-xs hover:bg-yellow-700 font-medium">
                        Edit
                      </Link>
                      <button onClick={() => handleDelete(member._id, member.name)} className="px-3 py-1.5 bg-red-600 text-white rounded text-xs hover:bg-red-700 font-medium ml-auto">
                        Delete
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          </>
        )}
      </div>

      {/* Payment Modal */}
      {paymentModal && paymentMember && (
        <div className="fixed inset-0 bg-black/70 flex items-end sm:items-center justify-center z-50" onClick={() => setPaymentModal(false)}>
          <div className="bg-gray-800 rounded-t-xl sm:rounded-xl p-5 sm:p-6 w-full sm:max-w-md sm:mx-4 max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <h3 className="text-white text-lg sm:text-xl font-bold mb-1">Update Payment</h3>
            <p className="text-gray-400 text-sm sm:text-base mb-4">{paymentMember.name} — ₹{paymentMember.feeAmount || 0}/month</p>

            <div className="space-y-4">
              <div>
                <label className="text-gray-400 text-sm">How many months?</label>
                <div className="flex gap-2 mt-2 flex-wrap">
                  {[1, 2, 3, 6, 12].map(m => (
                    <button key={m} type="button"
                      onClick={() => setPaymentData({ ...paymentData, months: m })}
                      className={`px-3 sm:px-4 py-2 rounded-lg font-bold text-sm transition-all ${
                        paymentData.months === m
                          ? 'bg-purple-600 text-white'
                          : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                      }`}>
                      {m}
                    </button>
                  ))}
                </div>
              </div>

              <div className="bg-gray-700/50 rounded-lg p-3 space-y-1">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Period Covered:</span>
                  <span className="text-purple-300 font-medium">{getCoverPeriod()}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Monthly Fee:</span>
                  <span className="text-white">₹{paymentMember.feeAmount || 0}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Months:</span>
                  <span className="text-white">{paymentData.months}</span>
                </div>
                <div className="flex justify-between text-sm border-t border-gray-600 pt-1">
                  <span className="text-gray-400 font-bold">Total:</span>
                  <span className="text-green-400 font-bold text-lg">₹{(paymentMember.feeAmount || 0) * paymentData.months}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Next Due Date:</span>
                  <span className="text-yellow-400">
                    {(() => {
                      const base = paymentMember.feeDueDate ? new Date(paymentMember.feeDueDate) : new Date();
                      const next = new Date(base);
                      next.setMonth(next.getMonth() + paymentData.months);
                      return next.toLocaleDateString();
                    })()}
                  </span>
                </div>
              </div>

              <div>
                <label className="text-gray-400 text-sm">Payment Method</label>
                <select
                  value={paymentData.paymentMethod}
                  onChange={e => setPaymentData({ ...paymentData, paymentMethod: e.target.value })}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 outline-none text-sm sm:text-base">
                  <option value="cash">Cash</option>
                  <option value="upi">UPI</option>
                  <option value="card">Card</option>
                  <option value="bank_transfer">Bank Transfer</option>
                </select>
              </div>

              <div>
                <label className="text-gray-400 text-sm">Remarks (optional)</label>
                <input type="text"
                  value={paymentData.remarks}
                  onChange={e => setPaymentData({ ...paymentData, remarks: e.target.value })}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 outline-none text-sm sm:text-base"
                  placeholder="e.g. Paid via Google Pay" />
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <button onClick={handlePaymentSubmit} disabled={submitting}
                className="flex-1 py-3 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 disabled:opacity-50 text-sm sm:text-base">
                {submitting ? 'Processing...' : 'Confirm Payment'}
              </button>
              <button onClick={() => setPaymentModal(false)}
                className="px-4 sm:px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 text-sm sm:text-base">
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
};

export default MemberList;
