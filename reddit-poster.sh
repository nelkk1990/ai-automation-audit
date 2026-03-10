#!/bin/bash

# Reddit Poster - Automated Posting Script
# Usage: ./reddit-poster.sh

# Configuration
SUBREDDITS=("smallbusiness" "ecommerce" "marketing" "SaaS" "Entrepreneur")
POSTS_FILE="reddit-posts.txt"
DELAY_BETWEEN_POSTS=3600  # 1 hour in seconds

# Check if posts file exists
if [ ! -f "$POSTS_FILE" ]; then
    echo "Error: $POSTS_FILE not found"
    echo "Creating template file..."
    cat > "$POSTS_FILE" << 'EOF'
POST 1 | r/smallbusiness | business_automation
Title: I analyzed 50 small businesses and found they're losing 10+ hours/week to these 5 tasks

Hey r/smallbusiness,

I've been helping businesses automate for the past year. Analyzed 50+ companies and found the same time-wasters everywhere:

1. Manual data entry (2-3 hours/week)
2. Email management (3-4 hours/week)  
3. Scheduling/appointments (2-3 hours/week)
4. Social media posting (2 hours/week)
5. Reporting/analytics (1-2 hours/week)

The crazy part? Most of these can be automated for under $50/month.

I'm doing free 5-minute audits this week. I'll analyze your specific workflow and tell you exactly what to automate first.

No pitch, just identifying your biggest time wasters.

Drop a comment with your biggest time waste or DM me "audit".
---
POST 2 | r/ecommerce | shopify_automation  
Title: Just helped a Shopify store automate order processing - saved them 8 hours/week

Hey e-commerce folks,

Been working with a Shopify store doing $50k/month. They were manually:
- Processing orders (2 hours/day)
- Updating inventory spreadsheets (1 hour/day)
- Sending shipping notifications (30 min/day)
- Handling returns via email (1 hour/day)

We automated 80% of it using:
- Shopify Flow (free)
- Zapier ($20/month)
- Airtable ($0, free tier)

Now they process orders in 30 minutes instead of 4+ hours.

Doing free automation audits for 5 e-commerce stores this week.

Comment "interested" or DM me.
EOF
    echo "Template created. Edit $POSTS_FILE with your posts."
    exit 1
fi

# Function to post to Reddit (manual instructions)
post_to_reddit() {
    local subreddit=$1
    local title=$2
    local body=$3
    
    echo "========================================="
    echo "POST TO REDDIT: r/$subreddit"
    echo "========================================="
    echo ""
    echo "Title:"
    echo "$title"
    echo ""
    echo "Body:"
    echo "$body"
    echo ""
    echo "-----------------------------------------"
    echo "MANUAL ACTION REQUIRED:"
    echo "1. Go to https://reddit.com/r/$subreddit/submit"
    echo "2. Copy the title above"
    echo "3. Copy the body above"  
    echo "4. Post it"
    echo "5. Come back and press ENTER to continue"
    echo "-----------------------------------------"
    read -p "Press ENTER after posting..."
}

# Parse and post
parse_posts() {
    local current_post=""
    local post_num=""
    local subreddit=""
    local flair=""
    local title=""
    local body=""
    local in_body=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check for post separator
        if [[ "$line" == "---" ]]; then
            # Post previous post if exists
            if [[ -n "$title" && -n "$body" ]]; then
                post_to_reddit "$subreddit" "$title" "$body"
                echo "Waiting $DELAY_BETWEEN_POSTS seconds before next post..."
                sleep $DELAY_BETWEEN_POSTS
            fi
            # Reset variables
            title=""
            body=""
            in_body=false
            continue
        fi
        
        # Parse post header
        if [[ "$line" == POST* ]]; then
            read -r post_num subreddit flair <<< "$line"
            continue
        fi
        
        # Parse title
        if [[ "$line" == Title:* ]]; then
            title="${line#Title: }"
            continue
        fi
        
        # Collect body
        if [[ -n "$title" && ! "$line" == POST* ]]; then
            if [[ -n "$body" ]]; then
                body="$body
$line"
            else
                body="$line"
            fi
        fi
    done < "$POSTS_FILE"
    
    # Post last post
    if [[ -n "$title" && -n "$body" ]]; then
        post_to_reddit "$subreddit" "$title" "$body"
    fi
}

# Main
echo "Reddit Poster Automation"
echo "========================"
echo ""
echo "This script will guide you through posting to Reddit."
echo "You'll need to manually copy/paste each post."
echo ""
read -p "Ready to start? (y/n): " ready

if [[ "$ready" == "y" || "$ready" == "Y" ]]; then
    parse_posts
    echo ""
    echo "All posts completed!"
else
    echo "Cancelled."
fi
