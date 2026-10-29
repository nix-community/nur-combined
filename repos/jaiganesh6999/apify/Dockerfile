FROM apify/actor-node:20

COPY package*.json ./

RUN npm install --omit=dev --no-audit

COPY . ./

CMD ["node", "main.js"]
