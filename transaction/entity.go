package transaction

import (
	"golang-crowdfunding/campaign"
	"golang-crowdfunding/user"
	"time"
)

type Transaction struct {
	ID            int
	TransactionID int
	UserID        int
	Amount        int
	Status        string
	Code          string
	User          user.User
	Campaign      campaign.Campaign
	CreatedAt     time.Time
	UpdatedAt     time.Time
}
