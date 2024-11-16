import React, { useState } from 'react';
import { useWeb3 } from '../context/Web3Context';
import './Home.css';

const Home = () => {
  const { account, setAccount } = useWeb3();
  const [isConnecting, setIsConnecting] = useState(false);
  const [error, setError] = useState(null);

  const connectWallet = async () => {
    setIsConnecting(true);
    setError(null);
    
    console.log('Attempting to connect to MetaMask...');
    
    // Check if MetaMask is installed
    if (typeof window.ethereum === 'undefined') {
      console.log('MetaMask is not installed');
      setError('Please install MetaMask to continue');
      setIsConnecting(false);
      return;
    }

    try {
      // Check if already connected
      const accounts = await window.ethereum.request({
        method: 'eth_accounts',
      });
      
      if (accounts.length > 0) {
        console.log('Already connected to account:', accounts[0]);
        setAccount(accounts[0]);
        setIsConnecting(false);
        return;
      }

      // Request connection
      console.log('Requesting account access...');
      const newAccounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });
      
      console.log('Connected to account:', newAccounts[0]);
      setAccount(newAccounts[0]);
      
    } catch (error) {
      console.error('Error details:', error);
      let errorMessage = 'Failed to connect to MetaMask';
      
      // Handle specific error cases
      if (error.code === 4001) {
        errorMessage = 'You rejected the connection request';
      } else if (error.code === -32002) {
        errorMessage = 'Please check MetaMask popup - connection request pending';
      }
      
      setError(errorMessage);
    } finally {
      setIsConnecting(false);
    }
  };

  // Add event listener for account changes
  React.useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
          setAccount(null);
        } else {
          setAccount(accounts[0]);
        }
      });
    }
  }, [setAccount]);

  return (
    <div className="home-container">
      {error && (
        <div className="error-message">
          {error}
        </div>
      )}
      <button 
        className={`connect-wallet-btn ${isConnecting ? 'connecting' : ''}`}
        onClick={connectWallet}
        disabled={isConnecting}
      >
        {isConnecting 
          ? 'Connecting...' 
          : account 
            ? `Connected: ${account.slice(0, 6)}...${account.slice(-4)}`
            : 'Connect Wallet'
        }
      </button>
      <div className="content">
        <h1>WELCOME TO THE LOTTERY DRAW</h1>
        <button className="buy-ticket-btn">Buy Ticket</button>
      </div>
    </div>
  );
};

export default Home;