import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Heading } from '../../components';
import { toast } from 'react-hot-toast';
import { BASE_URL } from '../../utils/fetchData';

const AddMember = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    contact: '',
    feeAmount: '',
    feeDueDate: '',
    membershipStart: new Date().toISOString().split('T')[0],
    membershipEnd: '',
  });
  const [profilePic, setProfilePic] = useState(null);
  const [preview, setPreview] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setProfilePic(file);
      setPreview(URL.createObjectURL(file));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name || !formData.email || !formData.password || !formData.contact) {
      toast.error("Name, Email, Password, and Contact are required");
      return;
    }
    if (formData.password.length < 6) {
      toast.error("Password must be at least 6 characters");
      return;
    }

    setSubmitting(true);
    try {
      // 1. Create the member
      const res = await axios.post(`${BASE_URL}/api/v1/member/add-member`, {
        ...formData,
        feeAmount: formData.feeAmount ? Number(formData.feeAmount) : 0,
      });

      if (res.data?.success) {
        // 2. Upload profile pic if selected
        if (profilePic && res.data.member._id) {
          const fd = new FormData();
          fd.append('profilePic', profilePic);
          await axios.put(`${BASE_URL}/api/v1/member/update-profile-pic/${res.data.member._id}`, fd, {
            headers: { 'Content-Type': 'multipart/form-data' },
          });
        }
        toast.success("Member added successfully!");
        navigate('/dashboard/admin/member-list');
      } else {
        toast.error(res.data?.message || "Error adding member");
      }
    } catch (err) {
      console.log(err);
      toast.error(err.response?.data?.message || "Error adding member");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Add New Member" />
      <div className="container mx-auto px-4 sm:px-6 py-6 sm:py-10 max-w-3xl">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Profile Picture */}
          <div className="flex flex-col items-center gap-4">
            <div className="w-28 h-28 rounded-full bg-gray-700 overflow-hidden border-4 border-blue-500">
              {preview ? (
                <img src={preview} alt="preview" className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-gray-400 text-4xl">?</div>
              )}
            </div>
            <label className="px-4 py-2 bg-blue-600 text-white rounded-lg cursor-pointer hover:bg-blue-700">
              Upload Photo
              <input type="file" accept="image/*" onChange={handleImageChange} className="hidden" />
            </label>
          </div>

          {/* Basic Info */}
          <div className="bg-gray-800 p-6 rounded-lg">
            <h3 className="text-white text-xl font-bold mb-4">Basic Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-gray-400 text-sm">Name *</label>
                <input type="text" name="name" value={formData.name} onChange={handleChange} required
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Email *</label>
                <input type="email" name="email" value={formData.email} onChange={handleChange} required
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Password *</label>
                <input type="password" name="password" value={formData.password} onChange={handleChange} required minLength={6}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Phone *</label>
                <input type="tel" name="contact" value={formData.contact} onChange={handleChange} required
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
            </div>
          </div>

          {/* Fee & Membership */}
          <div className="bg-gray-800 p-6 rounded-lg">
            <h3 className="text-white text-xl font-bold mb-4">Fee & Membership</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-gray-400 text-sm">Monthly Fee (₹)</label>
                <input type="number" name="feeAmount" value={formData.feeAmount} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Fee Due Date</label>
                <input type="date" name="feeDueDate" value={formData.feeDueDate} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Membership Start</label>
                <input type="date" name="membershipStart" value={formData.membershipStart} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Membership End</label>
                <input type="date" name="membershipEnd" value={formData.membershipEnd} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
            </div>
          </div>

          {/* Submit */}
          <div className="flex gap-4">
            <button type="submit" disabled={submitting}
              className="px-8 py-3 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 disabled:opacity-50 transition-all">
              {submitting ? 'Adding...' : 'Add Member'}
            </button>
            <button type="button" onClick={() => navigate('/dashboard/admin/member-list')}
              className="px-8 py-3 bg-gray-600 text-white font-bold rounded-lg hover:bg-gray-700 transition-all">
              Cancel
            </button>
          </div>
        </form>
      </div>
    </section>
  );
};

export default AddMember;
