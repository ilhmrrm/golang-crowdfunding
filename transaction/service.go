package transaction

import (
	"errors"
	"golang-crowdfunding/campaign"
)

type Service interface {
	GetTransactionsByCampignID(input GetCampaignTransactionsInput) ([]Transaction, error)
}

type service struct {
	repository Repository
	campaignRepository campaign.Repository
}

func NewService(repository Repository, campaignRepository campaign.Repository) *service {
	return &service{repository, campaignRepository}
}

func (s *service) GetTransactionsByCampignID(input GetCampaignTransactionsInput) ([]Transaction, error) {

	
	// get campaign
	campaign, err := s.campaignRepository.FindByID(input.ID)
	if err != nil {
		return []Transaction{}, err
	}
	
	// check campaign.user.id != user_d yang melakukan request
	if campaign.ID != input.User.ID {
		return []Transaction{}, errors.New("Not an owner of the campaign")
	}

	transactions ,err := s.repository.GetByCampignID(input.ID)
	if err != nil {
		return transactions, err
	}

	return transactions, nil
}


