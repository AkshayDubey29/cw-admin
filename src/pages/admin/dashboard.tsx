import React, { useEffect, useState } from 'react';
import {
  Box,
  Grid,
  Paper,
  Typography,
  Card,
  CardContent,
  CardHeader,
  IconButton,
  Chip,
  LinearProgress,
  Alert,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  VideoLibrary as ContentIcon,
  TrendingUp as AnalyticsIcon,
  Notifications as NotificationsIcon,
  Settings as SettingsIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '@/store';
import { fetchAdminProfile, fetchNotifications } from '@/store/slices/adminSlice';
import { setMetrics } from '@/store/slices/systemSlice';
import { adminApi } from '@/services/adminApi';

// Mock data for demonstration
const mockDashboardData = {
  totalUsers: 15420,
  activeUsers: 8920,
  totalContent: 45670,
  totalViews: 2340000,
  systemHealth: 98.5,
  recentActivity: [
    { id: 1, type: 'user_registration', message: 'New user registered', time: '2 minutes ago' },
    { id: 2, type: 'content_upload', message: 'New video uploaded', time: '5 minutes ago' },
    { id: 3, type: 'system_alert', message: 'High CPU usage detected', time: '10 minutes ago' },
  ],
  quickStats: {
    dailyActiveUsers: 8920,
    weeklyGrowth: 12.5,
    monthlyRevenue: 45600,
    systemUptime: 99.9,
  },
};

const Dashboard: React.FC = () => {
  const dispatch = useDispatch();
  const { user, isAuthenticated, isLoading, error } = useSelector(
    (state: RootState) => state.admin
  );
  const { metrics } = useSelector((state: RootState) => state.system);
  const [dashboardData, setDashboardData] = useState(mockDashboardData);

  useEffect(() => {
    if (isAuthenticated) {
      dispatch(fetchAdminProfile() as any);
      dispatch(fetchNotifications() as any);
      loadDashboardData();
    }
  }, [dispatch, isAuthenticated]);

  const loadDashboardData = async () => {
    try {
      const [statsResponse, metricsResponse] = await Promise.all([
        adminApi.getDashboardStats(),
        adminApi.getSystemMetrics(),
      ]);
      
      // Update dashboard data with real API response
      setDashboardData(prev => ({
        ...prev,
        ...statsResponse.data,
      }));
      
      dispatch(setMetrics(metricsResponse.data));
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    }
  };

  const StatCard: React.FC<{
    title: string;
    value: string | number;
    icon: React.ReactNode;
    color: string;
    trend?: string;
  }> = ({ title, value, icon, color, trend }) => (
    <Card sx={{ height: '100%' }}>
      <CardContent>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box>
            <Typography color="textSecondary" gutterBottom variant="h6">
              {title}
            </Typography>
            <Typography variant="h4" component="div">
              {value}
            </Typography>
            {trend && (
              <Chip
                label={trend}
                size="small"
                color={trend.includes('+') ? 'success' : 'error'}
                sx={{ mt: 1 }}
              />
            )}
          </Box>
          <Box
            sx={{
              backgroundColor: color,
              borderRadius: '50%',
              p: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );

  const SystemHealthCard: React.FC = () => (
    <Card>
      <CardHeader
        title="System Health"
        action={
          <IconButton onClick={loadDashboardData}>
            <RefreshIcon />
          </IconButton>
        }
      />
      <CardContent>
        <Box mb={2}>
          <Typography variant="h6" gutterBottom>
            Overall Health: {dashboardData.systemHealth}%
          </Typography>
          <LinearProgress
            variant="determinate"
            value={dashboardData.systemHealth}
            sx={{ height: 8, borderRadius: 4 }}
          />
        </Box>
        
        <Grid container spacing={2}>
          <Grid item xs={6}>
            <Typography variant="body2" color="textSecondary">
              CPU Usage
            </Typography>
            <Typography variant="h6">{metrics.cpu}%</Typography>
          </Grid>
          <Grid item xs={6}>
            <Typography variant="body2" color="textSecondary">
              Memory Usage
            </Typography>
            <Typography variant="h6">{metrics.memory}%</Typography>
          </Grid>
          <Grid item xs={6}>
            <Typography variant="body2" color="textSecondary">
              Disk Usage
            </Typography>
            <Typography variant="h6">{metrics.disk}%</Typography>
          </Grid>
          <Grid item xs={6}>
            <Typography variant="body2" color="textSecondary">
              Network
            </Typography>
            <Typography variant="h6">{metrics.network} Mbps</Typography>
          </Grid>
        </Grid>
      </CardContent>
    </Card>
  );

  const RecentActivityCard: React.FC = () => (
    <Card>
      <CardHeader title="Recent Activity" />
      <CardContent>
        {dashboardData.recentActivity.map((activity) => (
          <Box key={activity.id} mb={2} p={1} bgcolor="grey.50" borderRadius={1}>
            <Typography variant="body2">{activity.message}</Typography>
            <Typography variant="caption" color="textSecondary">
              {activity.time}
            </Typography>
          </Box>
        ))}
      </CardContent>
    </Card>
  );

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <LinearProgress sx={{ width: '50%' }} />
      </Box>
    );
  }

  if (error) {
    return (
      <Alert severity="error" sx={{ m: 2 }}>
        {error}
      </Alert>
    );
  }

  return (
    <Box sx={{ flexGrow: 1, p: 3 }}>
      <Box display="flex" alignItems="center" mb={3}>
        <DashboardIcon sx={{ mr: 1 }} />
        <Typography variant="h4">Dashboard</Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Quick Stats */}
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Users"
            value={dashboardData.totalUsers.toLocaleString()}
            icon={<PeopleIcon sx={{ color: 'white' }} />}
            color="#1976d2"
            trend="+12.5%"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Active Users"
            value={dashboardData.activeUsers.toLocaleString()}
            icon={<PeopleIcon sx={{ color: 'white' }} />}
            color="#2e7d32"
            trend="+8.2%"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Content"
            value={dashboardData.totalContent.toLocaleString()}
            icon={<ContentIcon sx={{ color: 'white' }} />}
            color="#ed6c02"
            trend="+15.3%"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Views"
            value={dashboardData.totalViews.toLocaleString()}
            icon={<AnalyticsIcon sx={{ color: 'white' }} />}
            color="#9c27b0"
            trend="+22.1%"
          />
        </Grid>

        {/* System Health */}
        <Grid item xs={12} md={6}>
          <SystemHealthCard />
        </Grid>

        {/* Recent Activity */}
        <Grid item xs={12} md={6}>
          <RecentActivityCard />
        </Grid>

        {/* Quick Actions */}
        <Grid item xs={12}>
          <Card>
            <CardHeader title="Quick Actions" />
            <CardContent>
              <Grid container spacing={2}>
                <Grid item>
                  <Chip
                    icon={<PeopleIcon />}
                    label="Manage Users"
                    clickable
                    onClick={() => window.location.href = '/admin/users'}
                  />
                </Grid>
                <Grid item>
                  <Chip
                    icon={<ContentIcon />}
                    label="Manage Content"
                    clickable
                    onClick={() => window.location.href = '/admin/content'}
                  />
                </Grid>
                <Grid item>
                  <Chip
                    icon={<AnalyticsIcon />}
                    label="View Analytics"
                    clickable
                    onClick={() => window.location.href = '/admin/analytics'}
                  />
                </Grid>
                <Grid item>
                  <Chip
                    icon={<NotificationsIcon />}
                    label="Notifications"
                    clickable
                    onClick={() => window.location.href = '/admin/notifications'}
                  />
                </Grid>
                <Grid item>
                  <Chip
                    icon={<SettingsIcon />}
                    label="Settings"
                    clickable
                    onClick={() => window.location.href = '/admin/settings'}
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
