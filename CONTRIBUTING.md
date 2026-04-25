# Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`rake test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Data Updates

When PSA releases new PSGC data:

1. Download the Excel file from https://psa.gov.ph/classification/psgc/
2. Run `rake "data:parse[data/PSGC-Filename.xlsx]"`
3. Commit the updated JSON files