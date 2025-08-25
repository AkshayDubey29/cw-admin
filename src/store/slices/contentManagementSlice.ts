import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface Content {
  id: string;
  title: string;
  type: 'video' | 'image' | 'text' | 'audio';
  status: 'draft' | 'published' | 'archived' | 'flagged';
  author: string;
  createdAt: string;
  updatedAt: string;
  views: number;
  likes: number;
  comments: number;
  thumbnail?: string;
}

export interface ContentManagementState {
  contents: Content[];
  selectedContent: Content | null;
  isLoading: boolean;
  error: string | null;
  filters: {
    type: string;
    status: string;
    search: string;
  };
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
}

const initialState: ContentManagementState = {
  contents: [],
  selectedContent: null,
  isLoading: false,
  error: null,
  filters: {
    type: '',
    status: '',
    search: '',
  },
  pagination: {
    page: 1,
    limit: 20,
    total: 0,
  },
};

const contentManagementSlice = createSlice({
  name: 'contentManagement',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    setSelectedContent: (state, action: PayloadAction<Content | null>) => {
      state.selectedContent = action.payload;
    },
    setFilters: (state, action: PayloadAction<Partial<ContentManagementState['filters']>>) => {
      state.filters = { ...state.filters, ...action.payload };
    },
    setPagination: (state, action: PayloadAction<Partial<ContentManagementState['pagination']>>) => {
      state.pagination = { ...state.pagination, ...action.payload };
    },
  },
});

export const {
  setLoading,
  setError,
  setSelectedContent,
  setFilters,
  setPagination,
} = contentManagementSlice.actions;

export default contentManagementSlice.reducer;
