// Quick test to verify time preference fix
const fs = require('fs');

// Read the slot finder code
const slotFinderCode = fs.readFileSync('/Users/hessammousavi/Documents/GitHub/xTask/slot_finder_node', 'utf8');

// Extract the getCategoryTimePreferences function for testing
const startMarker = 'function getCategoryTimePreferences(';
const endMarker = '\nfunction ';

const startIndex = slotFinderCode.indexOf(startMarker);
const nextFunctionIndex = slotFinderCode.indexOf(endMarker, startIndex + 1);
const functionCode = slotFinderCode.substring(startIndex, nextFunctionIndex);

console.log('Testing getCategoryTimePreferences function...\n');

// Simulate the function
eval(functionCode + '\n');

// Test cases
const testCases = [
    {
        name: 'Morning Health Task (Persian Walking)',
        task: {
            category: 'health',
            time_preference: 'morning',
            title: 'فردا صبح نیم‌ساعت پیاده‌روی کنم'
        }
    },
    {
        name: 'Evening Health Task',
        task: {
            category: 'health',
            time_preference: 'evening'
        }
    },
    {
        name: 'Health Task No Preference',
        task: {
            category: 'health'
        }
    },
    {
        name: 'Morning Technical Work',
        task: {
            category: 'technical work',
            time_preference: 'morning'
        }
    }
];

testCases.forEach(testCase => {
    console.log(`\n🧪 ${testCase.name}:`);
    console.log(`   Input: category="${testCase.task.category}", time_preference="${testCase.task.time_preference || 'none'}"`);
    
    const preferredHours = getCategoryTimePreferences(testCase.task);
    console.log(`   Result: [${preferredHours.join(', ')}]`);
    
    if (testCase.task.time_preference === 'morning') {
        const hasMorningHours = preferredHours.some(h => h >= 6 && h <= 10);
        console.log(`   ✅ Morning hours (6-10): ${hasMorningHours ? 'FOUND' : '❌ MISSING'}`);
    }
});

console.log('\n🎯 Summary: The time preference fix should now prioritize explicit time preferences over category defaults.');
