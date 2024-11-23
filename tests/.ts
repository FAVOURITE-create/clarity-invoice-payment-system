import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test invoice creation",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const recipient = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('invoice-payment', 'create-invoice', [
                types.uint(1000),
                types.principal(recipient.address),
                types.uint(9999999999)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk().expectUint(0);
        
        let getInvoice = chain.mineBlock([
            Tx.contractCall('invoice-payment', 'get-invoice', [
                types.uint(0)
            ], deployer.address)
        ]);
        
        const invoice = getInvoice.receipts[0].result.expectOk().expectSome();
        assertEquals(invoice['amount'], types.uint(1000));
        assertEquals(invoice['sender'], deployer.address);
        assertEquals(invoice['recipient'], recipient.address);
        assertEquals(invoice['paid'], false);
        assertEquals(invoice['cancelled'], false);
    }
});

Clarinet.test({
    name: "Test invoice payment",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const payer = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('invoice-payment', 'create-invoice', [
                types.uint(1000),
                types.principal(deployer.address),
                types.uint(9999999999)
            ], deployer.address),
            Tx.contractCall('invoice-payment', 'pay-invoice', [
                types.uint(0)
            ], payer.address)
        ]);
        
        block.receipts[0].result.expectOk();
        block.receipts[1].result.expectOk();
        
        let getInvoice = chain.mineBlock([
            Tx.contractCall('invoice-payment', 'get-invoice', [
                types.uint(0)
            ], deployer.address)
        ]);
        
        const invoice = getInvoice.receipts[0].result.expectOk().expectSome();
        assertEquals(invoice['paid'], true);
    }
});
