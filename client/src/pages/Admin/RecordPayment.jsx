import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Heading, Loader } from '../../components';
import { toast } from 'react-hot-toast';
import { BASE_URL } from '../../utils/fetchData';

const RecordPayment = () => {
  const { userId } = useParams();
  const navigate = useNavigate();
  const [member, setMember] = useState(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  const [formData, setFormData] = useState({
    months: 1,
    isPaid: true,
    paymentMethod: 'cash',
    remarks: '',
    receiptNumber: '',
    collectedBy: '',
  });

  useEffect(() => {
    fetchMember();
  }, [userId]);

  const fetchMember = async () => {
    try {
      const res = await axios.get(`${BASE_URL}/api/v1/member/get-member/${userId}`);
      if (res.data?.success) {
        setMember(res.data.member);
      }
    } catch (err) {
      console.log(err);
      toast.error("Error loading member");
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({ ...formData, [name]: type === 'checkbox' ? checked : value });
  };

  const totalAmount = member ? (member.feeAmount || 0) * formData.months : 0;

  const formatMonth = (d) => d.toLocaleString('en-IN', { month: 'short', year: 'numeric' });

  const getCoverPeriod = () => {
    if (!member) return '';
    const base = member.feeDueDate ? new Date(member.feeDueDate) : new Date();
    const from = new Date(base);
    const to = new Date(base);
    to.setMonth(to.getMonth() + Number(formData.months));
    return Number(formData.months) === 1 ? formatMonth(from) : `${formatMonth(from)} → ${formatMonth(to)}`;
  };

  const getNextDueDate = () => {
    if (!member) return '';
    const base = member.feeDueDate ? new Date(member.feeDueDate) : new Date();
    const next = new Date(base);
    next.setMonth(next.getMonth() + Number(formData.months));
    return next.toLocaleDateString();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.months || formData.months < 1) {
      toast.error("Select at least 1 month");
      return;
    }
    setSubmitting(true);
    try {
      const res = await axios.post(`${BASE_URL}/api/v1/fee/create-payment`, {
        userId,
        amount: totalAmount,
        months: Number(formData.months),
        isPaid: formData.isPaid,
        paymentMethod: formData.paymentMethod,
        remarks: formData.remarks,
        receiptNumber: formData.receiptNumber,
        collectedBy: formData.collectedBy,
      });
      if (res.data?.success) {
        toast.success("Payment recorded!");
        navigate(`/dashboard/admin/member/${userId}`);
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

  if (loading) return <Loader />;

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Record Payment" />
      <div className="container mx-auto px-4 sm:px-6 py-6 sm:py-10 max-w-2xl">
        {member && (
          <div className="bg-gray-800 p-4 rounded-lg mb-6">
            <h3 className="text-white text-lg sm:text-xl font-bold">{member.name}</h3>
            <p className="text-gray-400 text-sm sm:text-base">{member.contact} | {member.email}</p>
            <p className="text-gray-400 text-sm sm:text-base">Monthly Fee: ₹{member.feeAmount || 0}</p>
            <p className="text-gray-400 text-sm sm:text-base">Current Due: {member.feeDueDate ? new Date(member.feeDueDate).toLocaleDateString() : 'Not Set'}</p>
          </div>
        )}

        <form onSubmit={handleSubmit} className="bg-gray-800 p-4 sm:p-6 rounded-lg space-y-4">
          <div>
            <label className="text-gray-400 text-sm">How many months?</label>
            <div className="flex gap-2 mt-2 flex-wrap">
              {[1, 2, 3, 6, 12].map(m => (
                <button key={m} type="button"
                  onClick={() => setFormData({ ...formData, months: m })}
                  className={`px-3 sm:px-5 py-2 sm:py-3 rounded-lg font-bold text-sm transition-all ${
                    formData.months === m
                      ? 'bg-purple-600 text-white'
                      : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                  }`}>
                  {m} {m === 1 ? 'Mo' : 'Mo'}
                </button>
              ))}
            </div>
          </div>

          <div className="bg-gray-700/50 rounded-lg p-3 sm:p-4 space-y-1">
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Period Covered:</span>
              <span className="text-purple-300 font-medium">{getCoverPeriod()}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Monthly Fee:</span>
              <span className="text-white">₹{member?.feeAmount || 0}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Months:</span>
              <span className="text-white">{formData.months}</span>
            </div>
            <div className="flex justify-between text-sm border-t border-gray-600 pt-2">
              <span className="text-gray-400 font-bold">Total Amount:</span>
              <span className="text-green-400 font-bold text-lg sm:text-xl">₹{totalAmount}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Next Due Date:</span>
              <span className="text-yellow-400 font-medium">{getNextDueDate()}</span>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="text-gray-400 text-sm">Payment Method</label>
              <select name="paymentMethod" value={formData.paymentMethod} onChange={handleChange}
                className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none text-sm sm:text-base">
                <option value="cash">Cash</option>
                <option value="upi">UPI</option>
                <option value="card">Card</option>
                <option value="bank_transfer">Bank Transfer</option>
              </select>
            </div>
            <div>
              <label className="text-gray-400 text-sm">Collected By</label>
              <input type="text" name="collectedBy" value={formData.collectedBy} onChange={handleChange}
                className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none text-sm sm:text-base" />
            </div>
          </div>

          <div className="flex items-center gap-3">
            <input type="checkbox" name="isPaid" checked={formData.isPaid} onChange={handleChange} id="isPaid"
              className="w-5 h-5 rounded" />
            <label htmlFor="isPaid" className="text-white font-medium text-sm sm:text-base">Mark as Paid</label>
          </div>

          <div>
            <label className="text-gray-400 text-sm">Receipt Number</label>
            <input type="text" name="receiptNumber" value={formData.receiptNumber} onChange={handleChange}
              className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none text-sm sm:text-base" />
          </div>
          <div>
            <label className="text-gray-400 text-sm">Remarks</label>
            <textarea name="remarks" value={formData.remarks} onChange={handleChange} rows="2"
              className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none text-sm sm:text-base" />
          </div>

          <div className="flex gap-3 sm:gap-4 pt-4">
            <button type="submit" disabled={submitting}
              className="flex-1 sm:flex-none px-6 sm:px-8 py-3 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 disabled:opacity-50 transition-all text-sm sm:text-base">
              {submitting ? 'Recording...' : 'Record Payment'}
            </button>
            <button type="button" onClick={() => navigate(`/dashboard/admin/member/${userId}`)}
              className="flex-1 sm:flex-none px-6 sm:px-8 py-3 bg-gray-600 text-white font-bold rounded-lg hover:bg-gray-700 transition-all text-sm sm:text-base">
              Cancel
            </button>
          </div>
        </form>
      </div>
    </section>
  );
};

export default RecordPayment;
