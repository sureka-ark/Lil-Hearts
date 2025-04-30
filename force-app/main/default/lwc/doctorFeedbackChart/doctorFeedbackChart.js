import { LightningElement, wire,api } from 'lwc';
import getDoctorMetrics from '@salesforce/apex/DoctorDataController.getDoctorMetrics';
import ChartJS from '@salesforce/resourceUrl/chartjs_v280';
import { loadScript } from 'lightning/platformResourceLoader';

export default class DoctorFeedbackChart extends LightningElement {
    chart;
    doctorData = [];
    @api vetname
    
    @wire(getDoctorMetrics, {name: '$vetname'})
    wiredDoctorData({ error, data }) {
        if (data) {
            console.log(data)
            this.doctorData = data;
            this.renderChart(); // Call chart rendering after data is loaded
        } else if (error) {
            console.error('Error fetching doctor data:', error);
        }
    }

    renderedCallback() {
        console.log(this.vetname)
        if (!this.chart) {
            Promise.all([loadScript(this, ChartJS)])
                .then(() => {
                    this.renderChart();
                })
                .catch(error => {
                    console.error('Error loading ChartJS:', error);
                });
        }
    }

    renderChart() {
        if (this.chart) {
            this.chart.destroy(); // Destroy previous instance to avoid duplicates
        }

        if (!this.doctorData.length) {
            return;
        }

        const ctx = this.template.querySelector('canvas').getContext('2d');

        // Extract Data from API Response
        const labels = this.doctorData.map(record => record.dateOfCapture);
        const patientCounts = this.doctorData.map(record => record.patientCount);
        const feedbackScores = this.doctorData.map(record => record.feedbackScore);

        this.chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Patient Count',
                        data: patientCounts,
                        borderColor: 'blue',
                        backgroundColor: 'rgba(0, 0, 255, 0.1)',
                        yAxisID: 'y-axis-1',
                        fill: false
                    },
                    {
                        label: 'Feedback Score',
                        data: feedbackScores,
                        borderColor: 'yellow',
                        backgroundColor: 'rgba(185, 255, 8, 0.1)',
                        yAxisID: 'y-axis-2',
                        fill: false
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                scales: {
                    yAxes: [
                        {
                            id: 'y-axis-1',
                            type: 'linear',
                            position: 'left',
                            ticks: {
                                beginAtZero: true
                            }
                        },
                        {
                            id: 'y-axis-2',
                            type: 'linear',
                            position: 'right',
                            ticks: {
                                beginAtZero: true
                            }
                        }
                    ]
                }
            }
        });
    }
}