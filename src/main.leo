// The 'arc20' program.
program arc20.aleo {

    record Balance {
        owner: address,
        amount: u128,
    }

    // Mapping key of allowance
    struct AllowanceKeyData {
        payer: address,
        spender: address,
    }

    mapping balances: address => u128;
    mapping allowance: field => u128;


    // Authorize other accounts to spend tokens.
    transition approve(public spender_: address, public amount_: u128) {
        return then finalize(self.caller, spender_, amount_);
    }

    finalize approve(public caller: address, public spender: address, public amount: u128) {
        let key: field = get_allowance(caller, spender);
        Mapping::set(allowance, key, amount);
    }




    // Transfer public tokens.
    transition transfer(public to_: address, public amount_: u128) {
        return then finalize(self.caller, to_, amount_);
    }

    finalize transfer(public from: address, public to: address, public amount: u128) {
        // confirm token exists
        let user_total_balance: u128 = balances.get_or_use(from, 0u128);
        let is_enough_balance: bool = (user_total_balance>0u128 && user_total_balance>=amount) & true;

        //break is balance is zero or not enough
        assert_eq(is_enough_balance, true);


        let to_balance: u128 = balances.get_or_use(to, 0u128);

        balances.set(from, user_total_balance-amount);
        balances.set(to, to_balance+amount);
    }




    // Transfer public tokens from other accounts.
    transition transfer_from(
        public from_: address,
        public to_: address,
        public amount: u128
    ) {
        return then finalize(self.caller, from_, to_, amount);
    }

    finalize transfer_from(
        public caller: address,
        public from: address,
        public to: address,
        public amount: u128
    ) {
        // confirm token exists
        let key: field = get_allowance(from, caller);
        let allowance_balance: u128 = allowance.get_or_use(key, 0u128);

        let is_enough_allowance: bool = (allowance_balance>0u128 && allowance_balance>=amount) & true;
        assert_eq(is_enough_allowance, true); // break if allowance is to low

        let user_total_balance: u128 = balances.get_or_use(from, 0u128);
        let is_enough_balance: bool = (user_total_balance>0u128 && user_total_balance>=amount) & true;

        //break is balance is zero or not enough
        assert_eq(is_enough_balance, true);

        let caller_balance: u128 = balances.get_or_use(caller, 0u128);

        balances.set(from, user_total_balance-amount);
        balances.set(to, caller_balance+amount);
    }


    transition transfer_private(from_: Balance, to_: address, amount_: u128) -> (Balance, Balance) {
        let difference: u128 = from_.amount - amount_;

        // Produce a token record with the change amount for the sender.
        let remaining: Balance = Balance {
            owner: from_.owner,
            amount: difference,
        };

        // Produce a token record for the specified receiver.
        let transferred: Balance = Balance {
            owner: to_,
            amount: amount_,
        };

        // Output the sender's change record and the receiver's record.
        return (remaining, transferred);
    }





    // // The function `transfer_private_to_public` turns a specified token amount from a token record into public tokens for the specified receiver.
    // // This function preserves privacy for the sender's record, however it publicly reveals the token receiver and the token amount.
    transition transfer_private_to_public(from_: Balance, public to_: address, public amount: u128) -> Balance {
        // Checks the given token record has a sufficient token amount.
        // This `sub` operation is safe, and the proof will fail if an underflow occurs.
        // `difference` holds the change amount for the caller.
        let difference: u128 = from_.amount - amount;

        // Produces a token record with the change amount for the caller.
        let remaining: Balance = Balance {
            owner: to_,
            amount: difference,
        };

        // Output the sender's change record.
        // Increment the token amount publicly for the token receiver.
        return remaining then finalize(to_, amount);
    }

    finalize transfer_private_to_public(public to: address, public amount: u128) {
        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `transfer_private_to_public` is reverted.
        let receiver_amount: u128 = balances.get_or_use(to, 0u128);
        balances.set(to, receiver_amount + amount);
    }

    // The function `transfer_public_to_private` turns a specified token amount from `account` into a token record for the specified receiver.
    // This function preserves privacy for the receiver's record, however it publicly reveals the caller and the specified token amount.
    transition transfer_public_to_private(public receiver: address, public amount: u128) -> Balance {
        // mint a new private token
        let pt: Balance = Balance {
            owner: receiver,
            amount: amount,
        };
        let hash: field = BHP256::hash_to_field(pt);
        return pt then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public to_: address, public amount: u128) {
        // confirm token exists
        let user_total_balance: u128 = balances.get_or_use(to_, 0u128);
        let is_enough_balance: bool = (user_total_balance>0u128 && user_total_balance>=amount) & true;

        //break is balance is zero or not enough
        assert_eq(is_enough_balance, true);

        balances.set(to_, user_total_balance-amount);
    }



    // inlines

    // Build a key of the mapping `allowance`
    inline get_allowance(payer_: address, spender_: address) -> field {
        let payer: address = payer_;
        let spender: address = spender_;
        // copy to avoid compiling error
        return BHP256::hash_to_field(AllowanceKeyData {payer, spender});
    }
}
