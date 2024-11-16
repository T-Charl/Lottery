import React from 'react';
import './Header.css'; // Optional for styling

const Header = ({ onConnectWallet, isConnected }) => {
  return (
    <header className="header">
      
      <button className="connect-btn" onClick={onConnectWallet}>
        {isConnected ? 'Wallet Connected' : 'Connect Wallet'}
      </button>
    </header>
  );
};

export default Header;
