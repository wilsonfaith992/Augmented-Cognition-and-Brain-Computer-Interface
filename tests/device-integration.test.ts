import { describe, it, expect, beforeEach } from 'vitest'

describe('Device Integration', () => {
  let integratedDevices = {}
  
  const mockRegisterDevice = (deviceId, user, deviceType) => {
    integratedDevices[deviceId] = {
      user,
      deviceType,
      lastSync: Date.now()
    }
    return { success: true }
  }
  
  const mockUpdateDeviceSync = (deviceId, user) => {
    if (integratedDevices[deviceId] && integratedDevices[deviceId].user === user) {
      const newSyncTime = Date.now() + 1000; // Add 1 second to ensure a different timestamp
      integratedDevices[deviceId].lastSync = newSyncTime;
      return { success: true }
    }
    return { success: false, error: 'Unauthorized' }
  }
  
  const mockGetDeviceInfo = (deviceId) => {
    return integratedDevices[deviceId] || null
  }
  
  beforeEach(() => {
    integratedDevices = {}
  })
  
  it('should register and retrieve device information', () => {
    const user = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
    const deviceId = 'device123'
    const deviceType = 'EEG Headset'
    
    const result = mockRegisterDevice(deviceId, user, deviceType)
    expect(result.success).toBe(true)
    
    const deviceInfo = mockGetDeviceInfo(deviceId)
    expect(deviceInfo).not.toBeNull()
    expect(deviceInfo.user).toBe(user)
    expect(deviceInfo.deviceType).toBe(deviceType)
  })
  
  it('should update device sync', () => {
    const user = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
    const deviceId = 'device123'
    mockRegisterDevice(deviceId, user, 'EEG Headset')
    
    const initialSync = integratedDevices[deviceId].lastSync
    
    // Wait for a short time to ensure the timestamps are different
    return new Promise(resolve => setTimeout(resolve, 10)).then(() => {
      const result = mockUpdateDeviceSync(deviceId, user)
      expect(result.success).toBe(true)
      
      const updatedDeviceInfo = mockGetDeviceInfo(deviceId)
      expect(updatedDeviceInfo.lastSync).toBeGreaterThan(initialSync)
    })
  })
  
  it('should not allow unauthorized sync updates', () => {
    const user1 = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
    const user2 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG'
    const deviceId = 'device123'
    mockRegisterDevice(deviceId, user1, 'EEG Headset')
    
    const result = mockUpdateDeviceSync(deviceId, user2)
    expect(result.success).toBe(false)
  })
})

