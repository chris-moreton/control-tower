// This file was generated by counterfeiter
package releasedirfakes

import (
	"sync"

	"github.com/cloudfoundry/bosh-cli/releasedir"
)

type FakeConfig struct {
	NameStub        func() (string, error)
	nameMutex       sync.RWMutex
	nameArgsForCall []struct{}
	nameReturns     struct {
		result1 string
		result2 error
	}
	SaveNameStub        func(string) error
	saveNameMutex       sync.RWMutex
	saveNameArgsForCall []struct {
		arg1 string
	}
	saveNameReturns struct {
		result1 error
	}
	BlobstoreStub        func() (string, map[string]interface{}, error)
	blobstoreMutex       sync.RWMutex
	blobstoreArgsForCall []struct{}
	blobstoreReturns     struct {
		result1 string
		result2 map[string]interface{}
		result3 error
	}
	invocations      map[string][][]interface{}
	invocationsMutex sync.RWMutex
}

func (fake *FakeConfig) Name() (string, error) {
	fake.nameMutex.Lock()
	fake.nameArgsForCall = append(fake.nameArgsForCall, struct{}{})
	fake.recordInvocation("Name", []interface{}{})
	fake.nameMutex.Unlock()
	if fake.NameStub != nil {
		return fake.NameStub()
	} else {
		return fake.nameReturns.result1, fake.nameReturns.result2
	}
}

func (fake *FakeConfig) NameCallCount() int {
	fake.nameMutex.RLock()
	defer fake.nameMutex.RUnlock()
	return len(fake.nameArgsForCall)
}

func (fake *FakeConfig) NameReturns(result1 string, result2 error) {
	fake.NameStub = nil
	fake.nameReturns = struct {
		result1 string
		result2 error
	}{result1, result2}
}

func (fake *FakeConfig) SaveName(arg1 string) error {
	fake.saveNameMutex.Lock()
	fake.saveNameArgsForCall = append(fake.saveNameArgsForCall, struct {
		arg1 string
	}{arg1})
	fake.recordInvocation("SaveName", []interface{}{arg1})
	fake.saveNameMutex.Unlock()
	if fake.SaveNameStub != nil {
		return fake.SaveNameStub(arg1)
	} else {
		return fake.saveNameReturns.result1
	}
}

func (fake *FakeConfig) SaveNameCallCount() int {
	fake.saveNameMutex.RLock()
	defer fake.saveNameMutex.RUnlock()
	return len(fake.saveNameArgsForCall)
}

func (fake *FakeConfig) SaveNameArgsForCall(i int) string {
	fake.saveNameMutex.RLock()
	defer fake.saveNameMutex.RUnlock()
	return fake.saveNameArgsForCall[i].arg1
}

func (fake *FakeConfig) SaveNameReturns(result1 error) {
	fake.SaveNameStub = nil
	fake.saveNameReturns = struct {
		result1 error
	}{result1}
}

func (fake *FakeConfig) Blobstore() (string, map[string]interface{}, error) {
	fake.blobstoreMutex.Lock()
	fake.blobstoreArgsForCall = append(fake.blobstoreArgsForCall, struct{}{})
	fake.recordInvocation("Blobstore", []interface{}{})
	fake.blobstoreMutex.Unlock()
	if fake.BlobstoreStub != nil {
		return fake.BlobstoreStub()
	} else {
		return fake.blobstoreReturns.result1, fake.blobstoreReturns.result2, fake.blobstoreReturns.result3
	}
}

func (fake *FakeConfig) BlobstoreCallCount() int {
	fake.blobstoreMutex.RLock()
	defer fake.blobstoreMutex.RUnlock()
	return len(fake.blobstoreArgsForCall)
}

func (fake *FakeConfig) BlobstoreReturns(result1 string, result2 map[string]interface{}, result3 error) {
	fake.BlobstoreStub = nil
	fake.blobstoreReturns = struct {
		result1 string
		result2 map[string]interface{}
		result3 error
	}{result1, result2, result3}
}

func (fake *FakeConfig) Invocations() map[string][][]interface{} {
	fake.invocationsMutex.RLock()
	defer fake.invocationsMutex.RUnlock()
	fake.nameMutex.RLock()
	defer fake.nameMutex.RUnlock()
	fake.saveNameMutex.RLock()
	defer fake.saveNameMutex.RUnlock()
	fake.blobstoreMutex.RLock()
	defer fake.blobstoreMutex.RUnlock()
	return fake.invocations
}

func (fake *FakeConfig) recordInvocation(key string, args []interface{}) {
	fake.invocationsMutex.Lock()
	defer fake.invocationsMutex.Unlock()
	if fake.invocations == nil {
		fake.invocations = map[string][][]interface{}{}
	}
	if fake.invocations[key] == nil {
		fake.invocations[key] = [][]interface{}{}
	}
	fake.invocations[key] = append(fake.invocations[key], args)
}

var _ releasedir.Config = new(FakeConfig)
