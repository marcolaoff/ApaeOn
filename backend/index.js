const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const dotenv = require("dotenv");
const mercadopago = require("mercadopago");

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Config Mercado Pago (versão 1.5.14)
mercadopago.configure({
    access_token: process.env.MP_ACCESS_TOKEN
});

app.get("/", (req, res) => {
    res.send("API Mercado Pago funcionando!");
});

app.post("/pix", async (req, res) => {
    try {
        const { amount, email, fullName } = req.body;

        const payment = await mercadopago.payment.create({
            transaction_amount: Number(amount),
            description: "Pagamento via PIX",
            payment_method_id: "pix",
            payer: {
                email: email,
                first_name: fullName
            }
        });

        return res.status(200).json(payment.body);
    } catch (error) {
        console.error("Erro no PIX:", error);
        res.status(500).json({ error: error.message });
    }
});

app.post("/webhook", (req, res) => {
    console.log("Webhook recebido:", req.body);
    res.sendStatus(200);
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Servidor rodando na porta ${port}`));
