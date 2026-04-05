import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import axios from 'axios';
import { Heading, Loader } from '../../components';
import { toast } from 'react-hot-toast';
import { BASE_URL } from '../../utils/fetchData';

const EditMember = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [profilePic, setProfilePic] = useState(null);
  const [preview, setPreview] = useState(null);
  const [formData, setFormData] = useState({
    name: '', contact: '', city: '', address: '', gender: '', age: '',
    feeAmount: '', feeDueDate: '', membershipStart: '', membershipEnd: '',
    status: '',
  });

  useEffect(() => {
    fetchMember();
  }, [id]);

  const fetchMember = async () => {
    try {
      const res = await axios.get(`${BASE_URL}/api/v1/member/get-member/${id}`);
      if (res.data?.success) {
        const m = res.data.member;
        setFormData({
          name: m.name || '',
          contact: m.contact || '',
          city: m.city || '',
          address: m.address || '',
          gender: m.gender || '',
          age: m.age || '',
          feeAmount: m.feeAmount || '',
          feeDueDate: m.feeDueDate ? new Date(m.feeDueDate).toISOString().split('T')[0] : '',
          membershipStart: m.membershipStart ? new Date(m.membershipStart).toISOString().split('T')[0] : '',
          membershipEnd: m.membershipEnd ? new Date(m.membershipEnd).toISOString().split('T')[0] : '',
          status: m.status || 'active',
        });
        if (m.profilePic) setPreview(`${BASE_URL}${m.profilePic}`);
      }
    } catch (err) {
      console.log(err);
      toast.error("Error fetching member");
    } finally {
      setLoading(false);
    }
  };

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
    setSubmitting(true);
    try {
      const res = await axios.put(`${BASE_URL}/api/v1/member/update-member/${id}`, {
        ...formData,
        age: formData.age ? Number(formData.age) : null,
        feeAmount: formData.feeAmount ? Number(formData.feeAmount) : 0,
      });

      if (res.data?.success) {
        if (profilePic) {
          const fd = new FormData();
          fd.append('profilePic', profilePic);
          await axios.put(`${BASE_URL}/api/v1/member/update-profile-pic/${id}`, fd, {
            headers: { 'Content-Type': 'multipart/form-data' },
          });
        }
        toast.success("Member updated!");
        navigate('/dashboard/admin/member-list');
      } else {
        toast.error(res.data?.message || "Error updating member");
      }
    } catch (err) {
      console.log(err);
      toast.error("Error updating member");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return <Loader />;

  return (
    <section className='pt-10 bg-gray-900 min-h-screen'>
      <Heading name="Edit Member" />
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
              Change Photo
              <input type="file" accept="image/*" onChange={handleImageChange} className="hidden" />
            </label>
          </div>

          {/* Basic Info */}
          <div className="bg-gray-800 p-6 rounded-lg">
            <h3 className="text-white text-xl font-bold mb-4">Basic Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-gray-400 text-sm">Name</label>
                <input type="text" name="name" value={formData.name} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Phone</label>
                <input type="tel" name="contact" value={formData.contact} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Gender</label>
                <select name="gender" value={formData.gender} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none">
                  <option value="">Select</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <div>
                <label className="text-gray-400 text-sm">Age</label>
                <input type="number" name="age" value={formData.age} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">City</label>
                <input type="text" name="city" value={formData.city} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
              </div>
              <div>
                <label className="text-gray-400 text-sm">Status</label>
                <select name="status" value={formData.status} onChange={handleChange}
                  className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none">
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                  <option value="expired">Expired</option>
                </select>
              </div>
            </div>
            <div className="mt-4">
              <label className="text-gray-400 text-sm">Address</label>
              <textarea name="address" value={formData.address} onChange={handleChange} rows="2"
                className="w-full mt-1 px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-blue-500 outline-none" />
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
              {submitting ? 'Updating...' : 'Update Member'}
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

export default EditMember;
