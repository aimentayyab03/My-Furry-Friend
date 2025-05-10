//const functions = require('firebase-functions');
//const admin = require('firebase-admin');
//const stripe = require('stripe')(functions.config().stripe.secret);
//const cors = require('cors')({origin: true});
//
//// Initialize Firebase Admin SDK
//admin.initializeApp();
//
///**
// * Creates a Stripe Payment Intent for processing payments
// * @type {functions.HttpsFunction}
// */
//exports.createPaymentIntent = functions.https.onRequest(async (req, res) => {
//  // Enable CORS
//  return cors(req, res, async () => {
//    try {
//      // Validate request method
//      if (req.method !== 'POST') {
//        res.status(405).send('Method Not Allowed');
//        return;
//      }
//
//      const {amount, email, metadata} = req.body;
//
//      // Validate required fields
//      if (!amount || !email) {
//        res.status(400).json({error: 'Amount and email are required'});
//        return;
//      }
//
//      if (isNaN(amount) {
//        res.status(400).json({error: 'Amount must be a number'});
//        return;
//      }
//
//      // Create or retrieve Stripe customer
//      let customer;
//      try {
//        const customers = await stripe.customers.list({email});
//        customer = customers.data.length > 0 ?
//          customers.data[0] :
//          await stripe.customers.create({
//            email,
//            metadata: metadata || {},
//          });
//      } catch (customerError) {
//        console.error('Customer creation error:', customerError);
//        throw new Error('Failed to create or retrieve customer');
//      }
//
//      // Create PaymentIntent
//      let paymentIntent;
//      try {
//        paymentIntent = await stripe.paymentIntents.create({
//          amount: Math.round(Number(amount)), // Ensure amount is a number
//          currency: 'pkr',
//          customer: customer.id,
//          automatic_payment_methods: {enabled: true},
//          metadata: metadata || {},
//        });
//      } catch (paymentError) {
//        console.error('Payment intent creation error:', paymentError);
//        throw new Error('Failed to create payment intent');
//      }
//
//      // Create ephemeral key
//      let ephemeralKey;
//      try {
//        ephemeralKey = await stripe.ephemeralKeys.create(
//            {customer: customer.id},
//            {apiVersion: '2023-08-16'},
//        );
//      } catch (keyError) {
//        console.error('Ephemeral key creation error:', keyError);
//        throw new Error('Failed to create ephemeral key');
//      }
//
//      // Return success response
//      res.status(200).json({
//        status: 'success',
//        clientSecret: paymentIntent.client_secret,
//        customerId: customer.id,
//        ephemeralKey: ephemeralKey.secret,
//        paymentIntentId: paymentIntent.id,
//      });
//    } catch (error) {
//      console.error('Endpoint error:', error);
//      res.status(500).json({
//        status: 'error',
//        message: error.message || 'Internal server error',
//      });
//    }
//  });
//});