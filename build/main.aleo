program arc20.aleo;

record Balance:
    owner as address.private;
    amount as u128.private;

struct AllowanceKeyData:
    payer as address;
    spender as address;


mapping balances:
	key as address.public;
	value as u128.public;


mapping allowance:
	key as field.public;
	value as u128.public;



function approve:
    input r0 as address.public;
    input r1 as u128.public;
    async approve self.caller r0 r1 into r2;
    output r2 as arc20.aleo/approve.future;

finalize approve:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u128.public;
    cast r0 r1 into r3 as AllowanceKeyData;
    hash.bhp256 r3 into r4 as field;
    set r2 into allowance[r4];


function transfer:
    input r0 as address.public;
    input r1 as u128.public;
    async transfer self.caller r0 r1 into r2;
    output r2 as arc20.aleo/transfer.future;

finalize transfer:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u128.public;
    get.or_use balances[r0] 0u128 into r3;
    gt r3 0u128 into r4;
    gte r3 r2 into r5;
    and r4 r5 into r6;
    and r6 true into r7;
    assert.eq r7 true;
    get.or_use balances[r1] 0u128 into r8;
    sub r3 r2 into r9;
    set r9 into balances[r0];
    add r8 r2 into r10;
    set r10 into balances[r1];


function transfer_from:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u128.public;
    async transfer_from self.caller r0 r1 r2 into r3;
    output r3 as arc20.aleo/transfer_from.future;

finalize transfer_from:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u128.public;
    cast r1 r0 into r4 as AllowanceKeyData;
    hash.bhp256 r4 into r5 as field;
    get.or_use allowance[r5] 0u128 into r6;
    gt r6 0u128 into r7;
    gte r6 r3 into r8;
    and r7 r8 into r9;
    and r9 true into r10;
    assert.eq r10 true;
    get.or_use balances[r1] 0u128 into r11;
    gt r11 0u128 into r12;
    gte r11 r3 into r13;
    and r12 r13 into r14;
    and r14 true into r15;
    assert.eq r15 true;
    get.or_use balances[r0] 0u128 into r16;
    sub r11 r3 into r17;
    set r17 into balances[r1];
    add r16 r3 into r18;
    set r18 into balances[r2];


function transfer_private:
    input r0 as Balance.record;
    input r1 as address.private;
    input r2 as u128.private;
    sub r0.amount r2 into r3;
    cast r0.owner r3 into r4 as Balance.record;
    cast r1 r2 into r5 as Balance.record;
    output r4 as Balance.record;
    output r5 as Balance.record;


function transfer_private_to_public:
    input r0 as Balance.record;
    input r1 as address.public;
    input r2 as u128.public;
    sub r0.amount r2 into r3;
    cast r1 r3 into r4 as Balance.record;
    async transfer_private_to_public r1 r2 into r5;
    output r4 as Balance.record;
    output r5 as arc20.aleo/transfer_private_to_public.future;

finalize transfer_private_to_public:
    input r0 as address.public;
    input r1 as u128.public;
    get.or_use balances[r0] 0u128 into r2;
    add r2 r1 into r3;
    set r3 into balances[r0];


function transfer_public_to_private:
    input r0 as address.public;
    input r1 as u128.public;
    cast r0 r1 into r2 as Balance.record;
    hash.bhp256 r2 into r3 as field;
    async transfer_public_to_private self.caller r1 into r4;
    output r2 as Balance.record;
    output r4 as arc20.aleo/transfer_public_to_private.future;

finalize transfer_public_to_private:
    input r0 as address.public;
    input r1 as u128.public;
    get.or_use balances[r0] 0u128 into r2;
    gt r2 0u128 into r3;
    gte r2 r1 into r4;
    and r3 r4 into r5;
    and r5 true into r6;
    assert.eq r6 true;
    sub r2 r1 into r7;
    set r7 into balances[r0];
