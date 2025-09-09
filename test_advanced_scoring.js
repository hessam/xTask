// Test Advanced 10x Productivity Scoring Algorithm
console.log('=== TESTING ADVANCED 10X PRODUCTIVITY SCORING ===\n');

// Simulate the advanced scoring function (extracted from slot_finder_node)
function getCircadianEnergyLevel(hour) {
    const energyMap = {
        6: 30, 7: 50, 8: 70, 9: 90, 10: 95, 11: 85,
        12: 75, 13: 60, 14: 55, 15: 80, 16: 85,
        17: 75, 18: 65, 19: 55, 20: 45, 21: 35,
        22: 25, 23: 15, 0: 10, 1: 5, 2: 5, 3: 5, 4: 10, 5: 20
    };
    return energyMap[hour] || 50;
}

function getCategoryMultiplier(category, hour, complexity, duration) {
    const multipliers = {
        'technical work': {
            base: 1.2,
            peakHours: [9, 10, 11, 15, 16],
            peakBonus: complexity === 'complex' ? 40 : 25,
            flowBonus: duration >= 120 ? 30 : 0
        },
        'content work': {
            base: 1.15,
            peakHours: [10, 11, 14, 15, 16],
            peakBonus: 35,
            flowBonus: duration >= 90 ? 25 : 0
        },
        'learning': {
            base: 1.1,
            peakHours: [9, 10, 11, 16, 17],
            peakBonus: 30,
            flowBonus: duration >= 60 ? 20 : 0
        },
        'administrative': {
            base: 1.0,
            peakHours: [8, 9, 13, 14, 17],
            peakBonus: 15,
            flowBonus: 0
        },
        'health': {
            base: 1.05,
            peakHours: [6, 7, 8, 17, 18],
            peakBonus: 25,
            flowBonus: 0
        },
        'personal': {
            base: 1.0,
            peakHours: [8, 12, 17, 18, 19],
            peakBonus: 20,
            flowBonus: 0
        }
    };
    
    const config = multipliers[category] || multipliers['administrative'];
    let score = config.base * 20;
    
    if (config.peakHours.includes(hour)) {
        score += config.peakBonus;
    }
    
    score += config.flowBonus;
    return score;
}

function getUrgencyMultiplier(priority, daysUntilDue) {
    let urgencyScore = priority;
    
    if (daysUntilDue <= 0) urgencyScore *= 3;
    else if (daysUntilDue <= 1) urgencyScore *= 2.5;
    else if (daysUntilDue <= 3) urgencyScore *= 2;
    else if (daysUntilDue <= 7) urgencyScore *= 1.5;
    
    return Math.min(urgencyScore, 30);
}

// Test scenarios
const testScenarios = [
    {
        name: "Complex Technical Work - Morning Peak",
        task: {
            description: "Refactor authentication system",
            category: "technical work",
            complexity: "complex",
            priority: 8,
            estimated_duration: 180,
            due_date: "2025-09-12"
        },
        timeSlot: { hour: 9, duration: 240 },
        expected: "High score due to morning peak + complex work alignment"
    },
    {
        name: "Simple Admin Task - Afternoon",
        task: {
            description: "Update team calendar",
            category: "administrative", 
            complexity: "simple",
            priority: 3,
            estimated_duration: 30,
            due_date: null
        },
        timeSlot: { hour: 14, duration: 60 },
        expected: "Moderate score, admin work is flexible"
    },
    {
        name: "Content Creation - Creative Peak",
        task: {
            description: "Write blog post about new features",
            category: "content work",
            complexity: "medium",
            priority: 6,
            estimated_duration: 120,
            due_date: "2025-09-10"
        },
        timeSlot: { hour: 11, duration: 150 },
        expected: "High score due to creative peak + flow state buffer"
    },
    {
        name: "Urgent Learning - Peak Hours",
        task: {
            description: "Complete security training module",
            category: "learning",
            complexity: "medium", 
            priority: 9,
            estimated_duration: 90,
            due_date: "2025-09-09"
        },
        timeSlot: { hour: 10, duration: 120 },
        expected: "Very high score due to urgency + optimal learning time"
    },
    {
        name: "Personal Task - Evening",
        task: {
            description: "Plan weekend trip",
            category: "personal",
            complexity: "simple",
            priority: 4,
            estimated_duration: 45,
            due_date: null
        },
        timeSlot: { hour: 18, duration: 60 },
        expected: "Good score for personal evening time"
    }
];

// Run scoring tests
testScenarios.forEach((scenario, index) => {
    console.log(`\n${index + 1}. ${scenario.name}`);
    console.log(`Task: ${scenario.task.description}`);
    console.log(`Category: ${scenario.task.category} | Complexity: ${scenario.task.complexity} | Priority: ${scenario.task.priority}`);
    console.log(`Time Slot: ${scenario.timeSlot.hour}:00 for ${scenario.timeSlot.duration} minutes`);
    
    // Calculate scoring components
    const hour = scenario.timeSlot.hour;
    const energyLevel = getCircadianEnergyLevel(hour);
    const energyScore = energyLevel * 0.8;
    
    const cognitiveScore = getCategoryMultiplier(
        scenario.task.category, 
        hour, 
        scenario.task.complexity, 
        scenario.task.estimated_duration
    );
    
    // Calculate urgency
    let daysUntilDue = 999;
    if (scenario.task.due_date) {
        const dueDate = new Date(scenario.task.due_date);
        const now = new Date('2025-09-09'); // Current test date
        daysUntilDue = Math.ceil((dueDate - now) / (1000 * 60 * 60 * 24));
    }
    const urgencyScore = getUrgencyMultiplier(scenario.task.priority, daysUntilDue);
    
    // Flow state bonus
    let flowBonus = 0;
    const availableBuffer = scenario.timeSlot.duration - scenario.task.estimated_duration;
    if (scenario.task.complexity === 'complex' && availableBuffer >= 45) {
        flowBonus = 50;
    } else if (scenario.task.complexity === 'medium' && availableBuffer >= 30) {
        flowBonus = 25;
    }
    
    // Duration bonus
    let durationBonus = 0;
    if (scenario.timeSlot.duration >= scenario.task.estimated_duration * 1.5) {
        durationBonus = 25;
    }
    
    const totalScore = energyScore + cognitiveScore + urgencyScore + flowBonus + durationBonus;
    
    console.log(`📊 Score Breakdown:`);
    console.log(`   Circadian Energy: +${energyScore.toFixed(1)} (${energyLevel}% at ${hour}:00)`);
    console.log(`   Cognitive Match: +${cognitiveScore.toFixed(1)}`);
    console.log(`   Urgency: +${urgencyScore.toFixed(1)} (${daysUntilDue}d until due)`);
    if (flowBonus > 0) console.log(`   Flow State: +${flowBonus}`);
    if (durationBonus > 0) console.log(`   Duration Comfort: +${durationBonus}`);
    console.log(`🏆 TOTAL SCORE: ${totalScore.toFixed(1)}`);
    console.log(`💡 Expected: ${scenario.expected}`);
    console.log('─'.repeat(60));
});

// Show productivity insights
console.log(`\n🧠 === PRODUCTIVITY INSIGHTS ===`);
console.log(`✅ Best times for Technical Work: 9-11 AM, 3-4 PM`);
console.log(`✅ Best times for Content Creation: 10-11 AM, 2-5 PM`);
console.log(`✅ Best times for Learning: 9-11 AM, 4-5 PM`);
console.log(`✅ Administrative tasks: Flexible, avoid peak hours`);
console.log(`✅ Complex tasks need 45+ minute buffers`);
console.log(`✅ High priority + approaching deadline = major urgency bonus`);
console.log(`\n🚀 This 10x scoring system optimizes for:`);
console.log(`   1. Circadian rhythm alignment`);
console.log(`   2. Cognitive peak matching`);
console.log(`   3. Flow state protection`);
console.log(`   4. Context switching minimization`);
console.log(`   5. Deadline pressure management`);
