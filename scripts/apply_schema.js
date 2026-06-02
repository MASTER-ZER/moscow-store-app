const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const connectionString = 'postgresql://postgres.vfarjzrettrncygzvylc:xvMz2WkBQ6pRxtC6@aws-1-eu-central-1.pooler.supabase.com:5432/postgres';

async function main() {
  const client = new Client({ connectionString });
  
  try {
    console.log('Connecting to Supabase PostgreSQL...');
    await client.connect();
    console.log('Connected successfully.');

    const schemaPath = path.join(__dirname, '..', 'supabase', 'schema.sql');
    const sql = fs.readFileSync(schemaPath, 'utf-8');

    console.log(`Executing SQL schema (${sql.length} characters)...`);
    await client.query(sql);
    console.log('Schema executed successfully!');

  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await client.end();
    console.log('Disconnected.');
  }
}

main();
