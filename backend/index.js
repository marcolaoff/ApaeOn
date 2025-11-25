const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const dotenv = require("dotenv");
const crypto = require("crypto");
const axios = require("axios");

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Criar PIX Dinâmico via API oficial do Mercado Pago
app.post("/pix", async (req, res) => {
    try {
        const { amount, email, fullName } = req.body;

        // Idempotência obrigatória
        const idemKey = crypto.randomUUID();

        const response = await axios.post(
            "https://api.mercadopago.com/v1/payments",
            {
                transaction_amount: Number(amount),
                description: "Pagamento via PIX - ApaeOn",
                payment_method_id: "pix",
                payer: {
                    email: email,
                    first_name: fullName
                }
            },
            {
                headers: {
                    "Content-Type": "application/json",
                    "X-Idempotency-Key": idemKey,
                    Authorization: `Bearer ${process.env.MP_ACCESS_TOKEN}`
                }
            }
        );

        console.log("PIX criado:", response.data);

        return res.json(response.data);

    } catch (err) {
        console.error("Erro ao gerar PIX:", err.response?.data || err.message);
        res.status(500).json({
            error: err.response?.data || err.message
        });
    }
});

// Consulta pagamento
app.get("/payment/:id", async (req, res) => {
    try {
        const { id } = req.params;

        const response = await axios.get(
            `https://api.mercadopago.com/v1/payments/${id}`,
            {
                headers: {
                    Authorization: `Bearer ${process.env.MP_ACCESS_TOKEN}`
                }
            }
        );

        return res.json(response.data);
    } catch (err) {
        res.status(500).json({
            error: err.response?.data || err.message
        });
    }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Servidor rodando na porta ${port}`));
