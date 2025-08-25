import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

export interface User {
  id: string;
  email: string;
  name: string;
  role: 'user' | 'creator' | 'admin';
  status: 'active' | 'inactive' | 'suspended';
  createdAt: string;
  lastLogin: string;
  profileImage?: string;
  bio?: string;
  followers: number;
  following: number;
  posts: number;
}

export interface UserManagementState {
  users: User[];
  selectedUser: User | null;
  isLoading: boolean;
  error: string | null;
  filters: {
    status: string;
    role: string;
    search: string;
  };
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
}

const initialState: UserManagementState = {
  users: [],
  selectedUser: null,
  isLoading: false,
  error: null,
  filters: {
    status: '',
    role: '',
    search: '',
  },
  pagination: {
    page: 1,
    limit: 20,
    total: 0,
  },
};

// Mock async thunks (replace with actual API calls)
export const fetchUsers = createAsyncThunk(
  'userManagement/fetchUsers',
  async (params: { page: number; limit: number; filters: any }) => {
    // Mock API call
    return new Promise<{ users: User[]; total: number }>((resolve) => {
      setTimeout(() => {
        resolve({
          users: [],
          total: 0,
        });
      }, 1000);
    });
  }
);

export const updateUserStatus = createAsyncThunk(
  'userManagement/updateUserStatus',
  async ({ userId, status }: { userId: string; status: string }) => {
    // Mock API call
    return new Promise<User>((resolve) => {
      setTimeout(() => {
        resolve({} as User);
      }, 500);
    });
  }
);

const userManagementSlice = createSlice({
  name: 'userManagement',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    setSelectedUser: (state, action: PayloadAction<User | null>) => {
      state.selectedUser = action.payload;
    },
    setFilters: (state, action: PayloadAction<Partial<UserManagementState['filters']>>) => {
      state.filters = { ...state.filters, ...action.payload };
    },
    setPagination: (state, action: PayloadAction<Partial<UserManagementState['pagination']>>) => {
      state.pagination = { ...state.pagination, ...action.payload };
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUsers.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchUsers.fulfilled, (state, action) => {
        state.isLoading = false;
        state.users = action.payload.users;
        state.pagination.total = action.payload.total;
      })
      .addCase(fetchUsers.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Failed to fetch users';
      });
  },
});

export const {
  setLoading,
  setError,
  setSelectedUser,
  setFilters,
  setPagination,
} = userManagementSlice.actions;

export default userManagementSlice.reducer;
