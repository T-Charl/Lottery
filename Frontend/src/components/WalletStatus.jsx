import React from 'react';

const WalletStatus = ({ account }) => (
  <p style={styles.status}>
    {account ? `Connected: ${account}` : 'Wallet not connected'}
  </p>
);

const styles = {
  status: {
    fontSize: '1rem',
    color: account ? 'green' : 'red',
  },
};

export default WalletStatus;
