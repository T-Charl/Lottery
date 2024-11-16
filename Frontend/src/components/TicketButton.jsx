import React from 'react';

const TicketButton = ({ onBuyTicket }) => (
  <button onClick={onBuyTicket} style={styles.buyButton}>
    Buy Ticket
  </button>
);

const styles = {
  buyButton: {
    padding: '10px 20px',
    fontSize: '1.2rem',
    backgroundColor: '#000',
    color: '#fff',
    border: 'none',
    cursor: 'pointer',
    marginTop: '20px',
  },
};

export default TicketButton;
